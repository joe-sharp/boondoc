# frozen_string_literal: true

module Boondoc
  # Classes that turn the model into markdown.
  module Renderer
    # Shared helpers for all renderers.
    class Base
      # @param context [Context]
      def initialize(context)
        @context = context
      end

      private

      attr_reader :context

      def registry = context.registry
      def filter = context.filter
      def linker = context.linker
      def path_map = context.path_map

      def code(text)
        "`#{text}`"
      end

      # A fenced Ruby block whose fence is longer than any fence inside the source.
      def ruby(source)
        longest = source.scan(/^\s*(`{3,})/).flatten.map(&:size).max || 2
        fence = '`' * [3, longest + 1].max
        "#{fence}ruby\n#{source}\n#{fence}"
      end

      # Joins blocks into a document with exactly one blank line between them.
      def document(blocks)
        blocks.flatten.compact.map { |block| block.sub(/\A\n+/, '').rstrip }.reject(&:empty?).join("\n\n") << "\n"
      end

      # A one-line summary of an object, with references resolved.
      def summary(object, from)
        text = linker.text(object.docstring.summary, object: object, from: from)
        text = "**Deprecated.** #{text}".strip if object.docstring.tag?('deprecated')
        Markdown.table_cell(text)
      end

      def bullet(link, summary)
        summary.empty? ? "- #{link}" : "- #{link} — #{summary}"
      end
    end
  end
end
