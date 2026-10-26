# frozen_string_literal: true

module Boondoc
  module Model
    # One `@tag` from a docstring.
    #
    # Which fields are set depends on the tag: `@param` uses `name`, `types` and
    # `text`; `@example` uses `name` as its title; `@option` adds `key` and
    # `default`; `@overload` carries a `signature` and a nested `docstring`.
    Tag = Struct.new(:tag_name, :name, :types, :text, :key, :default, :signature, :docstring,
                     keyword_init: true) do
      def initialize(**)
        super
        self.text ||= ''
      end
    end

    # A parsed documentation comment: free markdown text plus tags.
    class Docstring
      # @return [String] the markdown body, without tags
      attr_reader :text
      # @return [Array<Tag>]
      attr_reader :tags
      # @return [Array<String>] names of YARD directives (`@!macro`, ...) found in the comment
      attr_reader :directives

      # @param text [String]
      # @param tags [Array<Tag>]
      # @param directives [Array<String>]
      def initialize(text = '', tags = [], directives = [])
        @text = text
        @tags = tags
        @directives = directives
      end

      # @param name [String] tag name without the `@`
      # @return [Array<Tag>]
      def tags_named(name)
        tags.select { |tag| tag.tag_name == name }
      end

      # @param name [String]
      # @return [Tag, nil] the first tag with that name
      def tag(name)
        tags.find { |tag| tag.tag_name == name }
      end

      # @param name [String]
      # @return [Boolean]
      def tag?(name)
        !tag(name).nil?
      end

      # @return [Boolean] true when there is neither text nor tags
      def empty?
        text.strip.empty? && tags.empty?
      end

      # @return [String] the first sentence of the first paragraph, on one line;
      #   falls back to the `@return` description when there is no body
      def summary
        paragraph = text.strip.split(/\n\s*\n/).first.to_s.gsub(/\s*\n\s*/, ' ')
        return paragraph[/\A.*?[.!?](?=\s|\z)/] || paragraph unless paragraph.empty?

        returned = tag('return')&.text.to_s.lines.first.to_s.strip
        returned.empty? ? '' : "Returns #{returned}"
      end
    end
  end
end
