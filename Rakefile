# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "boondoc/rake_task"

Boondoc::RakeTask.new(:docs)

Rake::Task["release"].clear
desc "Tag, push, build and publish a release (interactive)"
task(:release) { exec "bin/release" }

task default: %i[spec rubocop]
