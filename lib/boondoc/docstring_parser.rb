# frozen_string_literal: true

module Boondoc
  # Turns the text of a documentation comment into a {Model::Docstring}.
  #
  # A line starting with `@name` begins a tag; indented lines that follow belong
  # to it. Everything else is the markdown body.
  class DocstringParser
    TAG_LINE = /\A@(?<directive>!)?(?<name>[a-z_][\w.]*)(?:\s+(?<rest>.*))?\z/i
    NAMED = %w[param yieldparam attr attr_reader attr_writer].freeze
    FENCE = /\A\s*(?:```|~~~)/

    # @param text [String] comment text with the leading `#` already removed
    # @return [Model::Docstring]
    def self.parse(text)
      new.parse(text)
    end

    # @param text [String]
    # @return [Model::Docstring]
    def parse(text)
      @body = []
      @tags = []
      @directives = []
      @current = nil
      @fenced = false
      text.to_s.each_line(chomp: true) { |line| consume(line) }
      finish_tag
      Model::Docstring.new(@body.join("\n").strip, @tags, @directives)
    end

    private

    def consume(line)
      match = TAG_LINE.match(line) unless @fenced
      return start_tag(match) if match
      return @current[:lines] << line if @current && continuation?(line)

      finish_tag
      @fenced = !@fenced if FENCE.match?(line)
      @body << line
    end

    def start_tag(match)
      finish_tag
      @current = { name: match[:name], directive: !match[:directive].nil?, lines: [match[:rest].to_s] }
    end

    def continuation?(line)
      line.strip.empty? || line.start_with?(" ", "\t")
    end

    def finish_tag
      return unless @current

      current = @current
      @current = nil
      return @directives << current[:name] if current[:directive]

      first, *rest = current[:lines]
      @tags << build(current[:name], first.strip, dedent(rest))
    end

    def build(name, first, rest)
      case name
      when "example"  then Model::Tag.new(tag_name: name, name: first, text: rest)
      when "overload" then overload(first, rest)
      when "option"   then option(join(first, rest))
      when "see"      then see(join(first, rest))
      when *NAMED     then named(name, join(first, rest))
      else typed(name, join(first, rest))
      end
    end

    def overload(signature, rest)
      Model::Tag.new(tag_name: "overload", signature: signature, docstring: self.class.parse(rest))
    end

    # `@param name [Types] text` or `@param [Types] name text`
    def named(tag_name, text)
      types, text = TypeParser.extract(text)
      name, text = text.split(/\s+/, 2)
      types, text = TypeParser.extract(text.to_s) unless types
      Model::Tag.new(tag_name: tag_name, name: name, types: types, text: text.to_s.strip)
    end

    # `@return [Types] text`
    def typed(tag_name, text)
      types, text = TypeParser.extract(text)
      Model::Tag.new(tag_name: tag_name, types: types, text: text.strip)
    end

    # `@option opts [Types] :key (default) text`
    def option(text)
      name, text = text.split(/\s+/, 2)
      types, text = TypeParser.extract(text.to_s)
      key, text = text.split(/\s+/, 2)
      default = text.to_s[/\A\((.*?)\)\s*/, 1]
      text = text.to_s.sub(/\A\(.*?\)\s*/, "") if default
      Model::Tag.new(
        tag_name: "option",
        name: name,
        types: types,
        key: key,
        default: default,
        text: text.to_s.strip
      )
    end

    # `@see reference text`
    def see(text)
      name, text = text.split(/\s+/, 2)
      Model::Tag.new(tag_name: "see", name: name, text: text.to_s.strip)
    end

    def join(first, rest)
      [first, rest].reject(&:empty?).join("\n")
    end

    def dedent(lines)
      indent = lines.reject { |line| line.strip.empty? }.map { |line| line[/\A[ \t]*/].size }.min || 0
      lines.map { |line| line[indent..] || "" }.join("\n").strip
    end
  end
end
