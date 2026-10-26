# frozen_string_literal: true

module Boondoc
  # Splits a YARD type list such as `[String, Hash{Symbol => Array<Integer>}]`.
  module TypeParser
    OPENERS = { '[' => ']', '<' => '>', '(' => ')', '{' => '}' }.freeze
    # Duck types naming an operator method that contains bracket characters.
    OPERATOR_DUCK_TYPE = /#(?:<=>|<<|>>|[<>]=?|\[\]=?)/

    module_function

    # Takes a leading bracketed type list off a string.
    #
    # @param text [String]
    # @return [Array(Array<String>, String), Array(nil, String)] the types (nil
    #   when the text does not start with `[`) and the remaining text
    def extract(text)
      text = text.lstrip
      return [nil, text] unless text.start_with?('[')

      close = closing_index(text)
      return [nil, text] unless close

      [split(text[1...close]), text[(close + 1)..].lstrip]
    end

    # Splits on top-level commas, leaving nested brackets intact.
    #
    # @param list [String] the text between the outer brackets
    # @return [Array<String>]
    def split(list)
      types = ['']
      each_with_depth(list) do |char, _, depth|
        next types << +'' if char == ',' && depth.zero?

        types[-1] += char
      end
      types.map(&:strip).reject(&:empty?)
    end

    # @api private
    def closing_index(text)
      each_with_depth(text) { |_, index, depth| return index if depth.zero? }
      nil
    end

    # Yields each character with the nesting depth after it.
    #
    # @api private
    def each_with_depth(text)
      skip = operator_indices(text)
      depth = 0
      text.each_char.with_index do |char, index|
        depth += depth_change(text, char, index) unless skip.include?(index)
        yield char, index, depth
      end
    end

    # @api private
    def operator_indices(text)
      indices = []
      text.scan(OPERATOR_DUCK_TYPE) do
        match = Regexp.last_match
        indices.concat((match.begin(0)...match.end(0)).to_a)
      end
      indices
    end

    # @api private
    def depth_change(text, char, index)
      return 1 if OPENERS.key?(char)
      return 0 unless OPENERS.value?(char)

      # The `>` of a hash rocket (`=>`) does not close anything.
      char == '>' && index.positive? && text[index - 1] == '=' ? 0 : -1
    end
  end
end
