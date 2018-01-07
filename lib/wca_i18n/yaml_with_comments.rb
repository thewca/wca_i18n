require "yaml"

module WcaI18n
  module YamlWithComments
    CommentedValue = Struct.new(:comment, :value)

    def self.parse(text)
      parsed = YAML.safe_load(text)
      decorate_with_comments(parsed, [], text)
    end

    def self.decorate_with_comments(node, context, text)
      if node.kind_of?(Hash)
        node = node.map do |key, value|
          [key, decorate_with_comments(value, [*context, key], text)]
        end.to_h
      end

      comment = extract_comment(text, context)
      CommentedValue.new(comment, node)
    end

    def self.extract_comment(text, context)
      # Match any character, including newline.
      some_chars = '[\s\S]*?'

      comment_lines_group = '((?:\s*#.*\n)*)'
      key_matcher = "['\"]?%s['\"]?:"

      match_parent = ""
      context[0...-1].each do |key|
        match_parent = "#{match_parent}#{some_chars}#{key_matcher % key}"
      end
      regexp = Regexp.new "(#{match_parent}#{some_chars})#{comment_lines_group}\\s*#{key_matcher % context[-1]}"
      groups = text.match(regexp)
      # Group 1 is everything before the comment and the key.
      before = groups[1]
      # Group 2 contains the comments matched before the key.
      comments = groups[2]

      comments.split('#').map(&:strip!).reject(&:empty?).join("\n")
    end
  end
end
