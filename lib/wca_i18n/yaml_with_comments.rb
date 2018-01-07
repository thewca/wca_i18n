require "yaml"

module WcaI18n
  class YAMLWithComments < Struct.new(:comment, :value)
    def self.parse(text)
      _decorate_with_comments(YAML.safe_load(text), [], text)[1]
    end

    def strip_comments
      stripped_value = self.value

      if stripped_value.kind_of?(Hash)
        stripped_value = stripped_value.map do |key, value|
          [key, value.strip_comments]
        end.to_h
      end

      stripped_value
    end

    def self._decorate_with_comments(node, context, text)
      if node.kind_of?(Hash)
        node = node.map do |key, value|
          text, decorated = _decorate_with_comments(value, [*context, key], text)
          [key, decorated]
        end.to_h
      end

      trimmed_text, comment = _extract_comment(text, context)
      [trimmed_text, YAMLWithComments.new(comment, node)]
    end

    def self._extract_comment(text, context)
      return ["", ""] if context.empty?

      # Match any character, including newline.
      some_chars = /[\s\S]*?/

      comment_lines_group = /((?:^\s*#.*\n)*)/

      match_parent = ""
      context[0...-1].each do |key|
        match_parent = "#{match_parent}#{some_chars}#{build_key_matcher(key)}"
      end
      regexp = /(#{match_parent}#{some_chars})#{comment_lines_group}\s*#{build_key_matcher(context[-1])}/

      comment = nil
      text = text.sub(regexp) do
        # Group 1 is everything before the comment and the key.
        before = $1
        # Group 2 contains the comments matched before the key.
        comments = $2
        comment = comments.split('#').map(&:strip).reject(&:empty?).join("\n")

        # We return the beginning without the key, so that the current hash + key
        # are removed from the text, but the parents and the value stay in.
        before
      end
      throw "Could not find key: #{context} in given yaml text" unless comment

      [text, comment]
    end

    def self.build_key_matcher(key)
      /['\"]?#{key}['\"]?:/
    end
  end
end
