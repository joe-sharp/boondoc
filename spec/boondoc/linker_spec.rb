# frozen_string_literal: true

RSpec.describe Boondoc::Linker do
  it "warns about unresolved references to libraries boondoc itself loads" do
    _, reporter = render_source(<<~RUBY)
      # Uses {Thor::Shell}, {Boondoc::Linker}, and {Rake::Task}.
      class Foo; end
    RUBY
    expect(reporter.warnings).to eq(
      [
        "Foo: cannot resolve link to Thor::Shell",
        "Foo: cannot resolve link to Boondoc::Linker",
        "Foo: cannot resolve link to Rake::Task"
      ]
    )
  end

  describe "input that never closes" do
    let(:registry) { Boondoc::Model::Registry.new }
    let(:linker) do
      context = Boondoc::Context.new(
        config: Boondoc::Config.new(root: Dir.pwd, readme: false),
        registry: registry,
        reporter: quiet_reporter
      )
      context.linker
    end

    def seconds
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    end

    {
      "an open brace followed by 100 KB of spaces" => "{a#{" " * 100_000}",
      "repeated open braces with a title" => "{a  b " * 20_000,
      "100 KB of backticks" => "`" * 100_000
    }.each do |name, text|
      it "is returned unchanged, and quickly, for #{name}", :aggregate_failures do
        result = nil
        expect(seconds { result = linker.text(text, object: registry.root, from: "README.md") }).to be < 0.5
        expect(result).to eq(text)
      end
    end
  end

  describe "{include:file:...}" do
    def render_including(project, target)
      FileUtils.mkdir_p(File.join(project, "lib"))
      File.write(File.join(project, "lib", "foo.rb"), "# Text: {include:file:#{target}}\nclass Foo; end\n")
      reporter = quiet_reporter
      config = Boondoc::Config.new(root: project, readme: false)
      generator = Boondoc::Generator.new(config, reporter: reporter)
      generator.parse(config.source_files)
      [generator.render["Foo.md"], reporter]
    end

    def with_secret
      with_sandbox do |project, outside|
        File.write(File.join(outside, "secret.txt"), "SECRET=hunter2")
        yield project, outside
      end
    end

    it "inlines a file from the project" do
      with_sandbox do |project, _|
        File.write(File.join(project, "snippet.md"), "inside the project")
        page, = render_including(project, "snippet.md")
        expect(page).to include("Text: inside the project")
      end
    end

    {
      "an absolute path" => ->(outside) { File.join(outside, "secret.txt") },
      "a relative path" => ->(_) { "../outside/secret.txt" }
    }.each do |label, target|
      it "does not read a file outside the project through #{label}", :aggregate_failures do
        with_secret do |project, outside|
          page, reporter = render_including(project, target.call(outside))
          expect(page).not_to include("hunter2")
          expect(reporter.warnings.join).to include("cannot include")
        end
      end
    end

    it "does not read a file outside the project through a symlink" do
      with_secret do |project, outside|
        File.symlink(File.join(outside, "secret.txt"), File.join(project, "link.md"))
        page, = render_including(project, "link.md")
        expect(page).not_to include("hunter2")
      end
    end
  end

  it "does not warn about references to Ruby core and standard library classes", :aggregate_failures do
    pages, reporter = render_source(<<~RUBY)
      # Returns a {String}, {File::Stat}, {Pathname}, {Set}, or {JSON::ParserError}.
      class Foo; end
    RUBY
    expect(reporter.warnings).to eq([])
    expect(pages["Foo.md"]).to include("Returns a `String`, `File::Stat`, `Pathname`, `Set`, or `JSON::ParserError`.")
  end
end
