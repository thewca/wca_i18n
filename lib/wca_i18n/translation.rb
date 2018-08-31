require "json"
require "digest"
require "wca_i18n/yaml_with_original_hashes"

module WcaI18n
  class Translation

    attr_accessor :locale, :data

    def initialize(locale, file_content)
      self.locale = locale.to_s
      self.data = YAMLWithOriginalHashes.parse(file_content)
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

    def self.pluralization?(node)
      node.is_a?(Hash) && (node.keys & PLURALIZATION_KEYS).any?
    end
  end
end
