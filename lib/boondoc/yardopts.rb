# frozen_string_literal: true

require 'shellwords'

module Boondoc
  # The part of a project's `.yardopts` that Boondoc understands.
  #
  # Only the source globs, the extra files after `-`, `--files`, `--asset`, `--readme`,
  # `--title`, `--private`, `--protected`, and `--exclude` are used. `--output-dir`
  # is left out on purpose: in a `.yardopts` it names YARD's HTML directory, which is
  # usually ignored by git, while Boondoc's output is meant to be committed.
  # Everything else is collected in {#ignored} so the run can say what was skipped.
  #
  # @example
  #   Boondoc::Yardopts.parse('--title Foo -o doc lib - CHANGELOG.md').settings
  #   # => { title: "Foo", sources: ["lib"], files: ["CHANGELOG.md"] }
  class Yardopts
    FILE = '.yardopts'
    # Long options of the yard gem that take an argument.
    ARGUMENT_OPTIONS = %w[
      --load --plugin --db --exclude --api --no-api --hide-api --default-return --query --title
      --readme --main --files --asset --output-dir --markup --markup-provider --charset --template
      --template-path --format --locale --po-dir --tag --type-tag --type-name-tag --name-tag
      --title-tag --hide-tag --transitive-tag --non-transitive-tag
    ].freeze
    # Long options whose argument is optional; it is the next token unless that starts with `-`.
    OPTIONAL_ARGUMENT_OPTIONS = %w[--use-cache --yardopts --no-yardopts --embed-mixin].freeze
    SHORT_ARGUMENT_OPTIONS = {
      'b' => '--db', 'e' => '--load', 'o' => '--output-dir', 'm' => '--markup', 'M' => '--markup-provider',
      't' => '--template', 'p' => '--template-path', 'f' => '--format', 'r' => '--readme'
    }.freeze
    SHORT_OPTIONAL_ARGUMENT_OPTIONS = { 'c' => '--use-cache' }.freeze
    NON_RUBY_SOURCE = /\.(?:c|cc|cpp|cxx|h|hpp|y)\z/
    # How long a pattern from `--exclude` may take to match one path.
    REGEXP_TIMEOUT = 1.0

    # @param root [String] project directory
    # @return [Yardopts, nil] nil when the project has no `.yardopts`
    # @raise [Error] when the file cannot be read or parsed
    def self.read(root)
      path = File.join(root, FILE)
      return nil unless File.file?(path)

      parse(File.read(path))
    rescue SystemCallError => e
      raise Error, "could not read #{FILE}: #{e.message}"
    end

    # @param text [String] the contents of a `.yardopts`
    # @return [Yardopts]
    # @raise [Error] when the quoting is unbalanced or an `--exclude` pattern is not a regexp
    def self.parse(text)
      new(Shellwords.split(text))
    rescue ArgumentError => e
      raise Error, "could not read #{FILE}: #{e.message}"
    end

    # @return [Array<Regexp>] patterns from `--exclude`, matched against source paths
    attr_reader :exclude
    # @return [String, nil] the value of `--output-dir`, which Boondoc does not use
    attr_reader :output_dir
    # @return [Array<String>] options and sources that were read but are not used
    attr_reader :ignored

    # @param tokens [Array<String>] the file split into words, the way a shell would
    def initialize(tokens)
      @sources = []
      @files = []
      @assets = []
      @exclude = []
      @ignored = []
      @settings = {}
      read_tokens(tokens)
    end

    # @return [Hash{Symbol => Object}] Boondoc options: `sources`, `files`, `assets`, `readme`, `title`,
    #   `private`, and `protected`, for those that were given
    def settings
      @settings.merge({ sources: @sources, files: @files, assets: @assets }.reject { |_, list| list.empty? })
    end

    # @param output [String] the output directory Boondoc will use
    # @param root [String] project directory, for comparing paths
    # @return [Array<String>] messages telling the user what was left out
    def notes(output:, root:)
      notes = []
      if output_dir && File.expand_path(output_dir, root) != File.expand_path(output, root)
        notes << "ignoring --output-dir #{output_dir} from #{FILE}; writing to #{output} " \
                 '(set output in .boondoc.yml or pass -o to change)'
      end
      notes << "ignoring from #{FILE}: #{ignored.join(', ')}" if ignored.any?
      notes
    end

    private

    def read_tokens(tokens)
      tokens = tokens.dup
      extra = false
      until tokens.empty?
        token = tokens.shift
        if token == '-' then extra = true
        elsif extra then @files << token
        elsif token.start_with?('-') then read_option(token, tokens)
        else add_source(token)
        end
      end
    end

    def read_option(token, rest)
      name, value = split_option(token)
      value ||= rest.shift if takes_argument?(name, rest)
      apply(name, value)
    end

    def takes_argument?(name, rest)
      return false if rest.empty?

      ARGUMENT_OPTIONS.include?(name) || (OPTIONAL_ARGUMENT_OPTIONS.include?(name) && !rest.first.start_with?('-'))
    end

    # @return [Array(String, String)] the canonical long name (or the token itself) and its inline value, if any
    def split_option(token)
      return token.split('=', 2).values_at(0, 1) if token.start_with?('--')

      letter = token[1]
      long = SHORT_ARGUMENT_OPTIONS[letter] || SHORT_OPTIONAL_ARGUMENT_OPTIONS[letter]
      return [token, nil] unless long

      [long, token.length > 2 ? token[2..] : nil]
    end

    def apply(name, value)
      case name
      when '--output-dir' then @output_dir = value
      when '--title' then @settings[:title] = value
      when '--readme', '--main' then @settings[:readme] = value
      when '--files', '--asset' then add_list(name, value)
      when '--private', '--protected' then @settings[name.delete_prefix('--').to_sym] = true
      when '--exclude' then add_exclude(value)
      else @ignored << name
      end
    end

    # `--files` and `--asset` take comma-separated lists, as YARD does for `--files`.
    def add_list(name, value)
      list = name == '--asset' ? @assets : @files
      list.concat(value.to_s.split(','))
    end

    def add_source(glob)
      if glob.match?(NON_RUBY_SOURCE)
        @ignored << glob
      else
        @sources << glob
      end
    end

    def add_exclude(pattern)
      @exclude << Regexp.new(pattern.to_s, timeout: REGEXP_TIMEOUT)
    rescue RegexpError => e
      raise ArgumentError, "--exclude #{pattern.inspect} is not a regular expression (#{e.message})"
    end
  end
end
