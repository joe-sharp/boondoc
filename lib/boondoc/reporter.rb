# frozen_string_literal: true

module Boondoc
  # Collects warnings and prints progress messages.
  class Reporter
    # @return [Array<String>] every warning raised so far
    attr_reader :warnings

    # @param io [IO] where messages are written
    # @param quiet [Boolean] suppress informational messages (warnings still print)
    def initialize(io: $stderr, quiet: false)
      @io = io
      @quiet = quiet
      @warnings = []
    end

    # Records and prints a warning. Repeats of the same message are ignored.
    #
    # @param message [String]
    # @return [void]
    def warn(message)
      return if @warnings.include?(message)

      @warnings << message
      @io.puts("warning: #{message}")
    end

    # Prints an informational message unless quiet.
    #
    # @param message [String]
    # @return [void]
    def info(message)
      @io.puts(message) unless @quiet
    end
  end
end
