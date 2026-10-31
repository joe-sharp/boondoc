# frozen_string_literal: true

require "yaml"

module Boondoc
  # Options for one run, merged from defaults, `.yardopts`, `.boondoc.yml`, and the command line.
  class Config
    FILE = ".boondoc.yml"
    DEFAULTS = {
      sources: ["lib/**/*.rb"], exclude: [], output: "docs", index: "README.md",
      readme: nil, files: [], assets: [], copy_linked_assets: false, title: nil,
      private: false, protected: false, yard_macros: false,
      strict: false, force: false, quiet: false, allow_outside_output: false, yardopts: true
    }.freeze

    # What each option accepts: a type name from {CHECKS} per key.
    TYPES = {
      sources: :list, exclude: :list, files: :list, assets: :list, copy_linked_assets: :boolean,
      output: :string, index: :string, readme: :file_or_false, title: :optional_string,
      private: :boolean, protected: :boolean, yard_macros: :boolean, strict: :boolean,
      force: :boolean, quiet: :boolean, allow_outside_output: :boolean, yardopts: :boolean
    }.freeze
    # A test and a description for each type name in {TYPES}.
    CHECKS = {
      list: [->(value) { value.is_a?(String) || (value.is_a?(Array) && value.all?(String)) },
             "a string or a list of strings"],
      string: [->(value) { value.is_a?(String) }, "a string"],
      optional_string: [->(value) { value.nil? || value.is_a?(String) }, "a string"],
      file_or_false: [->(value) { value.nil? || value == false || value.is_a?(String) }, "a file name or false"],
      boolean: [->(value) { [true, false].include?(value) }, "true or false"]
    }.freeze

    attr_reader(*DEFAULTS.keys)
    # @return [String] absolute path of the project being documented
    attr_reader :root

    # Builds a config from `.yardopts` and `.boondoc.yml` (if present) with `overrides` on top.
    # Each option comes from the highest of those that sets it; lists are replaced, not merged.
    # `.yardopts` is skipped when `yardopts` is false in the file or the overrides.
    #
    # @param overrides [Hash{Symbol => Object}] options that win over the file;
    #   `:config` names an alternative config file
    # @param root [String] project directory
    # @return [Config]
    # @raise [Error] when the config file is missing, has unknown keys, or tries
    #   to set `allow_outside_output`, which only the caller may do
    def self.load(overrides = {}, root: Dir.pwd)
      overrides = overrides.transform_keys(&:to_sym)
      path = File.expand_path(overrides[:config] || FILE, root)
      raise Error, "config file not found: #{overrides[:config]}" if overrides[:config] && !File.file?(path)

      settings = read_file(path).merge(overrides.except(:config).compact)
      yardopts = Yardopts.read(root) unless settings[:yardopts] == false
      new(root: root, from_yardopts: yardopts, **with_yardopts(settings, yardopts))
    end

    # @param settings [Hash{Symbol => Object}] options from the config file and the caller
    # @param yardopts [Yardopts, nil]
    # @return [Hash{Symbol => Object}] `settings` over what `.yardopts` sets
    def self.with_yardopts(settings, yardopts)
      yardopts ? yardopts.settings.merge(settings) : settings
    end
    private_class_method :with_yardopts

    # @param path [String] the config file, which may not exist
    # @return [Hash{Symbol => Object}]
    # @raise [Error] when the file sets `allow_outside_output`
    def self.read_file(path)
      return {} unless File.file?(path)

      settings = YAML.safe_load_file(path, symbolize_names: true) || {}
      return settings unless settings.key?(:allow_outside_output)

      raise Error,
        "allow_outside_output cannot be set in a config file, because the project being " \
        "documented is not trusted to choose it; pass --allow-outside-output on the command line"
    end
    private_class_method :read_file

    # @param root [String] project directory
    # @param from_yardopts [Yardopts, nil] the project's `.yardopts`, whose `--exclude`
    #   patterns apply unless `exclude` is given and whose skipped options are reported
    #   by {#yardopts_notes}; its other settings are expected in `options` already
    # @param options [Hash{Symbol => Object}] any of the keys in {DEFAULTS}
    # @raise [Error] on unknown options, or an option of the wrong type
    def initialize(root: Dir.pwd, from_yardopts: nil, **options)
      unknown = options.keys - DEFAULTS.keys
      raise Error, "unknown option#{"s" if unknown.size > 1}: #{unknown.join(", ")}" if unknown.any?

      @root = File.expand_path(root)
      @yardopts_file = from_yardopts
      @yardopts_exclude_patterns = options.key?(:exclude) ? [] : from_yardopts&.exclude || []
      DEFAULTS.merge(options).each do |key, value|
        check_type(key, value)
        instance_variable_set(:"@#{key}", value)
      end
    end

    # @return [String] absolute path of the output directory
    # @raise [Error] when it is outside the project and `allow_outside_output`
    #   is not set, or when it is reached through a symlink inside the project
    def output_dir
      @output_dir ||= begin
        path = File.expand_path(output, root)
        check_output_inside(path) unless allow_outside_output
        link = Containment.symlink_between(path, root)
        raise Error, "output directory #{path} goes through the symlink #{link}" if link

        path
      end
    end

    # @return [Array<String>] what the run ignores from `.yardopts`, such as its `--output-dir`
    def yardopts_notes
      @yardopts_file ? @yardopts_file.notes(output: output, root: root) : []
    end

    # @return [String] the documentation title; defaults to the project directory name
    def title
      @title || File.basename(root)
    end

    # @return [Array<String>] Ruby files to parse, relative to {#root}; files
    #   that resolve outside the project are left out, see {#outside_sources}
    def source_files
      source_split.first
    end

    # @return [Array<String>] sources that resolve outside the project, through an
    #   absolute path, `../`, or a symlink, and are therefore not parsed
    def outside_sources
      source_split.last
    end

    # @return [String, nil] the README to use as the index page, relative to {#root}
    # @raise [Error] when an explicitly named README does not exist or is outside the project
    def readme_file
      return nil if readme == false
      return inside_project("README.md") if readme.nil? && File.file?(File.join(root, "README.md"))
      return nil if readme.nil?
      raise Error, "readme not found: #{readme}" unless File.file?(File.expand_path(readme, root))

      inside_project(relative(readme))
    end

    # @return [Array<String>] extra files to stitch in, relative to {#root}
    # @raise [Error] when a file is outside the project
    def extra_files
      (expand(files) - [readme_file]).each { |path| inside_project(path) }
    end

    private

    def check_type(key, value)
      test, description = CHECKS.fetch(TYPES.fetch(key))
      return if test.call(value)

      raise Error, "option `#{key}` must be #{description} (got #{value.inspect})"
    end

    def source_split
      @source_split ||= (expand(sources, ruby: true) - expand(exclude, ruby: true))
        .reject { |path| excluded_by_yardopts?(path) }
        .partition { |path| Containment.inside?(File.expand_path(path, root), root) }
    end

    def excluded_by_yardopts?(path)
      @yardopts_exclude_patterns.any? { |pattern| pattern.match?(path) }
    rescue Regexp::TimeoutError
      raise Error, "an --exclude pattern in .yardopts took too long to match #{path}"
    end

    def check_output_inside(path)
      return if path == root || path.start_with?(File.join(root, ""))

      raise Error,
        "output directory #{path} is outside the project (#{root}). A project must not choose where " \
        "boondoc writes. To write there anyway, pass --allow-outside-output; that is a security " \
        "risk if you do not trust the project, and it is how docs are kept outside the repository."
    end

    def expand(patterns, ruby: false)
      Array(patterns).flat_map do |pattern|
        pattern = File.join(pattern, "**", "*.rb") if ruby && File.directory?(File.expand_path(pattern, root))
        paths = Dir.glob(pattern, base: root).select { |path| File.file?(File.expand_path(path, root)) }
        paths.map { |path| relative(path) }
      end.uniq.sort
    end

    # Paths under the root become relative to it, with `..` segments resolved.
    def relative(path)
      absolute = File.expand_path(path, root)
      absolute.start_with?(File.join(root, "")) ? absolute.delete_prefix(File.join(root, "")) : path
    end

    # Files that are copied into the output must not come from elsewhere on the machine.
    def inside_project(path)
      return path if Containment.inside?(File.expand_path(path, root), root)

      raise Error, "#{path} is outside the project (#{root})"
    end
  end
end
