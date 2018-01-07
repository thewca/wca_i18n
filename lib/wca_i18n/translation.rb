require "wca_i18n/yaml_with_comments"
require "digest"

module WcaI18n
  TranslatedLeaf = Struct.new(:translated, :original_hash)

  class Translation
    PLURALIZATION_KEYS = %w(zero one two few many other).freeze

    attr_accessor :locale, :data

    def initialize(locale, file_content)
      self.locale = locale.to_s
      self.data = commented_yaml_to_translated_yaml(YamlWithComments.parse(file_content))
    end

    def compare_to(base)
      return diff_recursive(base.data[base.locale], self.data[self.locale], [])
    end

    def self.hash_translation(value)
      # If the key is a pluralization, we use all the subkeys to compute the hash
      # Please see this wiki page explaining why we do this: https://github.com/thewca/worldcubeassociation.org/wikigTranslating-the-website#translations-status-internals
      to_digest = pluralization?(value) ? JSON.generate(value) : value
      original_str = Digest::SHA1.hexdigest(to_digest)[0..6]
    end

    private def commented_yaml_to_translated_yaml(commented_value)
      if leaf?(commented_value.value)
        original_hash = extract_original_hash_from_comment(commented_value.comment)
        return TranslatedLeaf.new(commented_value.value, original_hash)
      end

      commented_value.value.map do |key, value|
        [key, commented_yaml_to_translated_yaml(value)]
      end.to_h
    end

    private def diff_recursive(base, translation, context)
      diff = { missing: [], unused: [], outdated: [] }
      base_leaf = base.is_a?(TranslatedLeaf)
      translation_leaf = translation.is_a?(TranslatedLeaf)

      if !base
        diff[:unused] += get_all_recursive(translation, context)
      elsif !translation
        diff[:missing] += get_all_recursive(base, context)
      elsif base_leaf && translation_leaf
        if translation.translated.nil?
          diff[:missing] << context
        elsif self.class.hash_translation(base.translated) != translation.original_hash
          diff[:outdated] << context
        end
      elsif base_leaf && !translation_leaf
        diff[:missing] << context
        diff[:unused] += get_all_recursive(translation, context)
      elsif !base_leaf && translation_leaf
        diff[:missing] += get_all_recursive(base, context)
        diff[:unused] << context
      else
        (base.keys | translation.keys).each do |key|
          merge_diffs!(diff, diff_recursive(base[key], translation[key], [*context, key]))
        end
      end

      diff
    end

    private def merge_diffs!(diff, other_diff)
      other_diff.each do |key, value|
        diff[key] += value
      end
      diff
    end

    private def get_all_recursive(node, context)
      return [ context ] if node.is_a?(TranslatedLeaf)

      node.map { |key, value| get_all_recursive(value, [*context, key]) }.flatten(1)
    end

    private def extract_original_hash_from_comment(comment)
      hashes = comment.scan(/original_hash:\s*(.+)/).flatten(1)
      if hashes.size == 0
        nil
      elsif hashes.size == 1
        hashes.first
      elsif hashes.size > 1
        throw "Too many #{HASHTAG} occurrences in: #{comment}"
      end
    end

    private def leaf?(node)
      # If the node is a pluralization it's also a leaf!
      node.nil? || node.is_a?(String) || self.class.pluralization?(node)
    end

    def self.pluralization?(node)
      node.is_a?(Hash) && (node.keys & PLURALIZATION_KEYS).any?
    end
  end
end
