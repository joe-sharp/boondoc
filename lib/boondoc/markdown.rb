# frozen_string_literal: true

module Boondoc
  # Just enough markdown awareness to leave code alone while rewriting prose.
  module Markdown
    FENCE = /\A {0,3}(`{3,}|~{3,})/
    INDENTED = /\A(?: {4}|\t)\s*\S/
    LIST_ITEM = /\A\s*(?:[-*+]|\d+[.)])\s/
    INLINE_CODE = /(?<!`)(`+)(?!`)(?:(?!\n\s*\n).)+?(?<!`)\1(?!`)/m

    module_function

    # Rewrites the prose of a markdown document, skipping fenced code blocks,
    # indented code blocks and inline code spans.
    #
    # @param text [String]
    # @yieldparam prose [String] a run of text outside any code
    # @yieldreturn [String] its replacement
    # @return [String]
    def map_prose(text, &)
      state = { fence: nil, indented: false, blank: true, list: false }
      output = +''
      prose = +''
      text.each_line do |line|
        next prose << line unless code_line?(line, state)

        output << map_inline(prose, &) << line
        prose = +''
      end
      output << map_inline(prose, &)
    end

    # @param text [String] a single table cell
    # @return [String] the text on one line with pipes escaped
    def table_cell(text)
      text.gsub(/\s*\n\s*/, ' ').gsub('|', '\\|').strip
    end

    # @api private
    def code_line?(line, state)
      return fence_line?(line, state) if state[:fence] || FENCE.match?(line)

      blank = line.strip.empty?
      code = !blank && INDENTED.match?(line) && indented_code_allowed?(state)
      state[:indented] = code || (blank && state[:indented])
      state[:list] = in_list?(line, blank, state)
      state[:blank] = blank
      code
    end

    # An indented line is code when it continues a code block, or starts one
    # after a blank line outside a list (where indentation means nesting).
    #
    # @api private
    def indented_code_allowed?(state)
      state[:indented] || (state[:blank] && !state[:list])
    end

    # @api private
    def in_list?(line, blank, state)
      LIST_ITEM.match?(line) || (state[:list] && (blank || line.start_with?(' ', "\t")))
    end

    # @api private
    def fence_line?(line, state)
      if state[:fence]
        closing = /\A {0,3}#{Regexp.escape(state[:fence][0])}{#{state[:fence].size},}\s*\z/
        state[:fence] = nil if closing.match?(line)
      else
        state[:fence] = FENCE.match(line)[1]
      end
      state[:blank] = false
      true
    end

    # @api private
    def map_inline(prose)
      return prose if prose.empty?

      output = +''
      position = 0
      prose.scan(INLINE_CODE) do
        match = Regexp.last_match
        output << yield(prose[position...match.begin(0)]) << match[0]
        position = match.end(0)
      end
      output << yield(prose[position..])
    end
  end
end
