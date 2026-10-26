# frozen_string_literal: true

require_relative 'lib/boondoc/version'

Gem::Specification.new do |spec|
  spec.name = 'boondoc'
  spec.version = Boondoc::VERSION
  spec.authors = ['Joe Sharp']
  spec.email = ['joesharp13@gmail.com']

  spec.summary = 'Markdown-only API documentation for Ruby, written from YARD-style comments'
  spec.description = 'boondoc reads YARD-style tags from Ruby source using Prism and writes plain ' \
                     'GitHub-flavored markdown: one file per class or module, with working relative ' \
                     'links, plus your README and guides stitched in. No HTML, no site to deploy and host.'
  spec.homepage = 'https://github.com/joe-sharp/boondoc'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{Boondoc::VERSION}"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[
                      lib/
                      exe/
                      CHANGELOG.md
                      CODE_OF_CONDUCT.md
                      README.md
                      LICENSE.txt
                    ])
    end
  end
  spec.bindir = 'exe'
  spec.executables = ['boondoc']
  spec.require_paths = ['lib']

  spec.add_dependency 'prism', '~> 1.0'
  spec.add_dependency 'thor', '~> 1.3'
end
