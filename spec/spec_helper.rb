# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
  end
end

require "boondoc"
require "stringio"
require "tmpdir"

require_relative "support/fixture_helper"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FixtureHelper

  # Specs tagged :yard need the optional yard gem (bundle without the yard group to skip them).
  config.filter_run_excluding(:yard) unless Gem::Specification.find_all_by_name("yard").any?
end
