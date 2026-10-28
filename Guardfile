# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme

# Prevent informational messages from Guard
logger level: :warn

guard :rubocop, cli: "--format progress --format json --out tmp/rubocop.json ",
                all_on_start: true, all_after_pass: true do
  watch(/.+\.rb$/)
  watch(/bin/)
  watch(/Guardfile/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: "bundle exec rspec --format progress --format json --out tmp/rspec.json",
              all_on_start: true, all_after_pass: true do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Golden files are compared by the generator spec
  watch(%r{^spec/fixtures/}) { rspec.spec_dir }
end

# Regenerate the docs when their sources change, and record the outcome for guard :status
guard :boondoc, status_file: "tmp/docs_status.txt"

# Time boondoc against the table in docs/Performance.md; slow on code changes only
guard :shell, all_on_start: true do
  watch(%r{^((lib|exe)/.+\.rb|docs/Performance\.md)$}) { `bin/benchmark_status` }
end

# One status line for the guards above, last so it runs after them
guard :status, segments: {
  "RuboCop" => { rubocop: "tmp/rubocop.json" },
  "Tests" => { rspec: "tmp/rspec.json" },
  "Docs" => "tmp/docs_status.txt",
  "Bench" => { file: "tmp/benchmark_status.txt",
               states: { slow: { display: "🐢 (%{1}s vs %{2}s)", severity: :failed } } }
}
