# frozen_string_literal: true

module Boondoc
  module Frontend
    # Finds the comment block that documents a given line of a parsed file.
    class Comments
      IGNORED = /\A#(?:!|\s*(?:rubocop:|frozen_string_literal:|encoding:|typed:|:nodoc:))/
      DIRECTIVE = /^\s*@!\w/

      # @param result [::Prism::ParseResult]
      def initialize(result)
        @blocks = {}
        @trailing = {}
        group(result.comments.grep(::Prism::InlineComment))
      end

      # @param line [Integer] the line a definition starts on
      # @return [String, nil] the text of the comment block ending on the line above
      def docstring_for(line)
        @blocks[line - 1]
      end

      # @param line [Integer]
      # @return [Boolean] true when the line carries a trailing `# :nodoc:`
      def nodoc?(line)
        @trailing[line].to_s.include?(':nodoc:')
      end

      # @return [Array<Integer>] last lines of comment blocks that contain YARD directives
      def directive_lines
        @blocks.select { |_, text| DIRECTIVE.match?(text) }.keys
      end

      private

      def group(comments)
        run = []
        comments.each do |comment|
          next @trailing[comment.location.start_line] = comment.location.slice if comment.trailing?

          flush(run) unless adjacent?(run.last, comment)
          run << comment
        end
        flush(run)
      end

      def adjacent?(previous, comment)
        previous.nil? || (previous.location.start_line + 1 == comment.location.start_line &&
          previous.location.start_column == comment.location.start_column)
      end

      def flush(run)
        return if run.empty?

        text = clean(run.map { |comment| comment.location.slice })
        @blocks[run.last.location.start_line] = text unless text.strip.empty?
        run.clear
      end

      def clean(lines)
        lines = lines.grep_v(IGNORED).map { |line| line.delete_prefix('#').rstrip }
        indent = lines.reject(&:empty?).map { |line| line[/\A */].size }.min || 0
        lines.map { |line| line[indent..] || '' }.join("\n")
      end
    end
  end
end
