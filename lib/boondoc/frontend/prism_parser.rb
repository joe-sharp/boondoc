# frozen_string_literal: true

module Boondoc
  module Frontend
    # Parses Ruby files with Prism and fills a {Model::Registry}.
    class PrismParser
      # @param registry [Model::Registry]
      # @param reporter [Reporter]
      def initialize(registry, reporter)
        @registry = registry
        @reporter = reporter
      end

      # @param path [String] file to parse
      # @param label [String] the path to record on objects (usually relative to the project)
      # @return [void]
      def parse_file(path, label: path)
        parse(File.read(path), label)
      end

      # @param source [String] Ruby source
      # @param label [String] file name to record on objects
      # @return [void]
      def parse(source, label = "(source)")
        result = ::Prism.parse(source)
        return syntax_error(label, result) if result.failure?

        comments = Comments.new(result)
        result.value.accept(Visitor.new(@registry, label, comments))
        comments.directive_lines.each { |line| @registry.directive_sites << "#{label}:#{line}" }
      end

      private

      def syntax_error(label, result)
        @reporter.warn("#{label}: skipped, syntax error: #{result.errors.first.message}")
      end
    end
  end
end
