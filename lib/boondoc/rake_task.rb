# frozen_string_literal: true

require "rake"
require "rake/tasklib"
require "boondoc"

module Boondoc
  # Defines a Rake task that generates the documentation.
  #
  # @example
  #   require 'boondoc/rake_task'
  #
  #   Boondoc::RakeTask.new(:docs) do |t|
  #     t.options = { output: 'docs', files: ['CHANGELOG.md'], strict: true }
  #   end
  class RakeTask < ::Rake::TaskLib
    # @return [Symbol] the task name
    attr_accessor :name
    # @return [Hash{Symbol => Object}] options passed to {Config.load}
    attr_accessor :options

    # @param name [Symbol]
    # @yieldparam task [RakeTask] the task, for setting {#options}
    def initialize(name = :docs)
      super()
      @name = name
      @options = {}
      yield self if block_given?
      define
    end

    private

    def define
      desc "Generate markdown documentation with boondoc"
      task(name) { Generator.new(Config.load(options)).run }
    end
  end
end
