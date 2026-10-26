# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in boondoc.gemspec
gemspec

gem 'irb'
gem 'rake', '~> 13.0'
gem 'rspec', '~> 3.0'
gem 'rubocop', '~> 1.21'
gem 'rubocop-performance', '~> 1.25'
gem 'rubocop-rspec', '~> 3.6'
gem 'simplecov', '~> 0.22', require: false

# Optional at runtime: only needed for `boondoc --yard-macros`.
group :yard do
  gem 'yard', '~> 0.9'
end

group :development do
  gem 'guard', '~> 2.20'
  gem 'guard-boondoc'
  gem 'guard-rspec', '~> 4.7'
  gem 'guard-rubocop', '~> 1.5'
  gem 'guard-shell', '~> 0.7'
  gem 'guard-status'
  gem 'ostruct' # guard-rspec's DSL requires it; no longer a default gem in Ruby 4.0
end
