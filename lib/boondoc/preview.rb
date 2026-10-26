# frozen_string_literal: true

module Boondoc
  # Serves generated docs locally using the `gh markdown-preview` extension of
  # the GitHub CLI.
  #
  # The previewer resolves links relative to the directory it was started in,
  # so it is always started from inside the output directory.
  class Preview
    EXTENSION = 'yusukebe/gh-markdown-preview'
    DEFAULT_HOST = '127.0.0.1'
    LOOPBACK_HOSTS = %w[::1 localhost].freeze
    SILENT = { out: File::NULL, err: File::NULL }.freeze

    # @param directory [String] the directory holding the generated docs
    # @param host [String] address the previewer binds to
    # @param port [Integer, nil] port to listen on; the previewer's default when nil
    # @yieldreturn [Boolean] whether the extension may be installed; asked only
    #   when it is missing
    def initialize(directory, host: DEFAULT_HOST, port: nil, &confirm_install)
      @directory = directory
      @host = host
      @port = port
      @confirm_install = confirm_install
    end

    # Starts the previewer and blocks until it exits.
    #
    # @return [void]
    # @raise [Error] when the docs, the GitHub CLI, or the extension are missing
    def start
      raise Error, "#{@directory} does not exist; run `boondoc` first to generate the docs" unless docs?
      raise Error, 'serve needs the GitHub CLI (gh); see https://cli.github.com' unless gh?

      install unless extension?
      warn_exposed unless loopback?
      serve
    end

    private

    def loopback?
      LOOPBACK_HOSTS.include?(@host) || @host.start_with?('127.')
    end

    # The extension answers `/__/md?path=` for any path, not only the docs, and
    # does not check the Host header, so whoever can reach the port can read
    # every file the current user can.
    def warn_exposed
      warn "boondoc: serving on #{@host} exposes the preview to the network. gh markdown-preview will " \
           'return any file the current user can read, not only the docs. Use the default 127.0.0.1 ' \
           'unless everyone who can reach this machine is trusted.'
    end

    def docs?
      File.directory?(@directory)
    end

    def gh?
      system('gh', '--version', **SILENT) == true
    end

    def extension?
      system('gh', 'markdown-preview', '--version', **SILENT) == true
    end

    def install
      manual = "install it with `gh extension install #{EXTENSION}`"
      raise Error, "serve needs the gh markdown-preview extension; #{manual}" unless @confirm_install&.call
      raise Error, "could not install the extension; #{manual}" unless system('gh', 'extension', 'install', EXTENSION)
    end

    def serve
      command = ['gh', 'markdown-preview', '--host', @host]
      command.push('--port', @port.to_s) if @port
      system(*command, chdir: @directory)
    rescue Interrupt
      nil
    end
  end
end
