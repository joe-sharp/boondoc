# frozen_string_literal: true

require "thor"

module Boondoc
  # The `boondoc` command.
  class CLI < Thor
    COMMANDS = %w[generate serve version help].freeze
    COMMAND_FLAGS = %w[-h --help -v --version].freeze

    # Runs the CLI, treating a bare `boondoc [GLOBS]` as `boondoc generate [GLOBS]`.
    #
    # @param argv [Array<String>]
    # @return [void]
    def self.start_with_default(argv)
      known = COMMANDS.include?(argv.first) || COMMAND_FLAGS.include?(argv.first)
      start(known ? argv : ["generate", *argv])
    end

    # @return [Boolean] exit non-zero when a command fails
    def self.exit_on_failure?
      true
    end

    desc "generate [GLOBS]", "Write markdown documentation (default command)"
    long_desc <<~DESC
      Parses the Ruby files matching GLOBS (default: lib/**/*.rb) and writes one markdown
      file per class or module, plus an index, into the output directory.

      Options can also be set in .boondoc.yml using the same names with underscores
      (sources, exclude, output, index, readme, files, assets, copy_linked_assets, title, private,
      protected, yard_macros, strict, yardopts). allow_outside_output can only be given on the command line.

      The output directory must be inside the project, and not reached through a symlink.
      Sources outside the project are skipped with a warning.
    DESC
    option :output, aliases: "-o", type: :string, desc: "Output directory (default: docs)"
    option :index, type: :string, desc: "Name of the index page (default: README.md)"
    option :readme, type: :string, desc: "File to use as the index page (default: README.md if present)"
    option :skip_readme, type: :boolean, desc: "Do not include a README in the index page"
    option :files, type: :array, desc: "Extra markdown files or globs to stitch in"
    option :assets, type: :array, desc: "Files, directories, or globs to copy into the output (FROM or FROM:DIR)"
    option :copy_linked_assets,
      type: :boolean,
      desc: "Also copy the files that pages embed, such as images in the README"
    option :exclude, type: :array, desc: "Ruby files or globs to leave out"
    option :title, type: :string, desc: "Title for the index page when there is no README"
    option :private, type: :boolean, desc: "Include private methods and @private objects"
    option :protected, type: :boolean, desc: "Include protected methods"
    option :yard_macros, type: :boolean, desc: "Expand @!macro, @!method, and @!attribute using the yard gem"
    option :yardopts, type: :boolean, desc: "Read .yardopts (default; --no-yardopts to skip it)"
    option :strict, type: :boolean, desc: "Exit non-zero if there are warnings"
    option :force, type: :boolean, desc: "Overwrite files in the output directory that boondoc did not write"
    option :allow_outside_output,
      type: :boolean,
      desc: "Allow an output directory outside the project (a security risk if the " \
            "project is not trusted; for docs kept outside the repository)"
    option :config, aliases: "-c", type: :string, desc: "Config file (default: .boondoc.yml)"
    option :quiet, aliases: "-q", type: :boolean, desc: "Only print warnings and errors"
    def generate(*globs)
      Generator.new(Config.load(overrides(globs))).run
    rescue Error => e
      raise Thor::Error, "boondoc: #{e.message}"
    end

    desc "serve", "Preview the generated docs in a browser with gh markdown-preview"
    long_desc <<~DESC
      Starts the gh markdown-preview extension of the GitHub CLI from inside the output
      directory, so the links between pages work. Offers to install the extension when
      it is missing. Run `boondoc` first to generate the docs.
    DESC
    option :output, aliases: "-o", type: :string, desc: "Directory holding the docs (default: docs)"
    option :allow_outside_output, type: :boolean, desc: "Allow a docs directory outside the project"
    option :host, type: :string, default: Preview::DEFAULT_HOST, desc: "Address to bind"
    option :port, aliases: "-p", type: :numeric, desc: "Port to listen on (default: 3333)"
    option :config, aliases: "-c", type: :string, desc: "Config file (default: .boondoc.yml)"
    def serve
      config = Config.load(options.slice("output", "config", "allow_outside_output").transform_keys(&:to_sym))
      Preview.new(config.output_dir, host: options[:host], port: options[:port]) do
        yes?("The gh markdown-preview extension is not installed. Install #{Preview::EXTENSION} now? [y/N]")
      end.start
    rescue Error => e
      raise Thor::Error, "boondoc: #{e.message}"
    end

    desc "version", "Print the boondoc version"
    def version
      puts Boondoc::VERSION
    end
    map %w[-v --version] => :version

    private

    def overrides(globs)
      settings = options.to_h.transform_keys(&:to_sym)
      settings[:readme] = false if settings.delete(:skip_readme)
      settings[:sources] = globs unless globs.empty?
      settings
    end
  end
end
