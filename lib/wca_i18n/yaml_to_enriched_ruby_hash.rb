require "psych"

module WcaI18n
  PLURALIZATION_KEYS = %w(zero one two few many other).freeze
  ORIGINAL_HASH_TAG = "#original_hash: ".freeze
  TranslatedLeaf = Struct.new(:translated, :original_hash)

  # Re-implement some parts of the ToRuby emitter to inject our TranslatedLeaf where needs be
  class YAMLToEnrichedRubyHash < Psych::Visitors::ToRuby
    def self.create(original_hashes_map)
      class_loader = Psych::ClassLoader.new
      scanner      = Psych::ScalarScanner.new class_loader
      new(scanner, class_loader, original_hashes_map)
    end

    def self.parse(text)
      tree = Psych.parser.parse(text)
      emitter = self.create(text)
      # Not sure why, but "accept" returns an array with one element.
      # Probably because the root of the YAML is a sequence by default?
      emitter.accept(tree.handler.root).first
    end

    def initialize(*args, text)
      super(*args)
      _build_original_hashes_by_line_from_text(text)
    end

    def pluralization_map?(v)
      return false unless v.is_a?(Psych::Nodes::Mapping)
      v.children.each_slice(2) do |k,v|
        return true if WcaI18n::PLURALIZATION_KEYS.include?(accept(k))
      end
      return false
    end

    # Copy from the revive_hash method in https://github.com/ruby/psych/blob/e9e4567adefc52e6511df7060851bce9fe408082/lib/psych/visitors/to_ruby.rb
    # Except we override the generic case with our code.
    def revive_hash hash, o
      o.children.each_slice(2) { |k,v|
        key = accept(k)
        val = accept(v)

        if key == SHOVEL && k.tag != "tag:yaml.org,2002:str"
          case v
          when Nodes::Alias, Nodes::Mapping
            begin
              hash.merge! val
            rescue TypeError
              hash[key] = val
            end
          when Nodes::Sequence
            begin
              h = {}
              val.reverse_each do |value|
                h.merge! value
              end
              hash.merge! h
            rescue TypeError
              hash[key] = val
            end
          else
            hash[key] = val
          end
        else
          # This is where we handle the translated key
          if v.is_a?(Psych::Nodes::Scalar) && !WcaI18n::PLURALIZATION_KEYS.include?(key)
            # For scalar value, the start line registered is the correct line
            # We assume that the '#original_hash: ' comment comes on the line before.
            original_hash = @original_hashes_by_line.delete(v.start_line - 1)
            val = WcaI18n::TranslatedLeaf.new(val, original_hash)
          end
          if pluralization_map?(v)
            # For mappings, the start line registered is the line of the first key/value!
            original_hash = @original_hashes_by_line.delete(v.start_line - 2)
            val = WcaI18n::TranslatedLeaf.new(val, original_hash)
          end
          hash[key] = val
        end
      }
      hash
    end

    def _build_original_hashes_by_line_from_text(text)
      @original_hashes_by_line = {}.tap do |hash|
        # Build a hash mapping a line number to its comment
        text.each_line.with_index do |line, index|
          stripped_line = line.strip
          if stripped_line.start_with?(ORIGINAL_HASH_TAG)
            hash[index] = stripped_line[ORIGINAL_HASH_TAG.length..-1]
          end
        end
      end
    end
  end
end
