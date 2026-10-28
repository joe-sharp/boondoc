# frozen_string_literal: true

# Helpers for parsing snippets and rendering the fixture projects.
module FixtureHelper
  def fixture_root(name)
    File.expand_path("../fixtures/#{name}", __dir__)
  end

  def quiet_reporter
    Boondoc::Reporter.new(io: StringIO.new)
  end

  # Parses a Ruby snippet and returns the registry.
  def parse_source(source, reporter: quiet_reporter)
    registry = Boondoc::Model::Registry.new
    Boondoc::Frontend::PrismParser.new(registry, reporter).parse(source, "test.rb")
    Boondoc::References.new(registry).expand
    registry
  end

  # Renders a fixture project in memory.
  #
  # @return [Array(Hash{String => String}, Boondoc::Reporter)] pages and the reporter
  def render_fixture(name, **)
    reporter = quiet_reporter
    config = Boondoc::Config.new(root: fixture_root(name), **)
    generator = Boondoc::Generator.new(config, reporter: reporter)
    generator.parse(config.source_files)
    [generator.render, reporter]
  end

  # Renders a Ruby snippet as a one-file project in memory.
  #
  # @return [Array(Hash{String => String}, Boondoc::Reporter)] pages and the reporter
  def render_source(source)
    Dir.mktmpdir("boondoc") do |dir|
      FileUtils.mkdir_p(File.join(dir, "lib"))
      File.write(File.join(dir, "lib", "test.rb"), source)
      reporter = quiet_reporter
      config = Boondoc::Config.new(root: dir, readme: false)
      generator = Boondoc::Generator.new(config, reporter: reporter)
      generator.parse(config.source_files)
      [generator.render, reporter]
    end
  end

  # Yields an empty project directory and a sibling directory outside it.
  def with_sandbox
    Dir.mktmpdir("boondoc") do |dir|
      project = File.join(dir, "project")
      outside = File.join(dir, "outside")
      FileUtils.mkdir_p([project, outside])
      yield project, outside
    end
  end

  # Copies a fixture project into a temporary directory and yields its path.
  def with_project(name)
    Dir.mktmpdir("boondoc") do |dir|
      FileUtils.cp_r("#{fixture_root(name)}/.", dir)
      FileUtils.rm_rf(File.join(dir, "expected"))
      yield dir
    end
  end
end

# A project (with an empty `lib`) and a sibling directory outside it, removed after each example.
RSpec.shared_context "with a sandbox" do
  let(:sandbox_dir) { Dir.mktmpdir("boondoc") }
  let(:project) { File.join(sandbox_dir, "project").tap { |dir| FileUtils.mkdir_p(File.join(dir, "lib")) } }
  let(:outside) { File.join(sandbox_dir, "outside").tap { |dir| FileUtils.mkdir_p(dir) } }

  after { FileUtils.rm_rf(sandbox_dir) }
end
