# frozen_string_literal: true

RSpec.describe Boondoc::Config do
  it "has sensible defaults", :aggregate_failures do
    config = described_class.new(root: fixture_root("sample"))
    expect(config.output).to eq("docs")
    expect(config.readme_file).to eq("README.md")
    expect(config.source_files).to eq(%w[lib/sample.rb lib/sample/circle.rb lib/sample/shape.rb lib/sample/util.rb])
    expect(config.title).to eq("sample")
  end

  it "expands directories, applies excludes and expands extra files", :aggregate_failures do
    config = described_class.new(
      root: fixture_root("sample"),
      sources: ["lib"],
      exclude: ["lib/sample/*.rb"],
      files: ["guides/*.md", "README.md"]
    )
    expect(config.source_files).to eq(["lib/sample.rb"])
    expect(config.extra_files).to eq(["guides/intro.md"])
  end

  it "rejects unknown options" do
    expect { described_class.new(bogus: 1) }.to raise_error(Boondoc::Error, /unknown option: bogus/)
  end

  it "raises when a named readme is missing" do
    config = described_class.new(root: fixture_root("sample"), readme: "NOPE.md")
    expect { config.readme_file }.to raise_error(Boondoc::Error, /readme not found/)
  end

  describe "files outside the project" do
    def secret(outside)
      File.join(outside, "secret.md").tap { |path| File.write(path, "SECRET=hunter2") }
    end

    it "refuses a readme outside the project" do
      with_sandbox do |project, outside|
        config = described_class.new(root: project, readme: secret(outside))
        expect { config.readme_file }.to raise_error(Boondoc::Error, /outside the project/)
      end
    end

    it "refuses extra files outside the project, by absolute or relative path", :aggregate_failures do
      with_sandbox do |project, outside|
        [File.join(File.dirname(secret(outside)), "*.md"), "../outside/*.md"].each do |pattern|
          expect { described_class.new(root: project, files: [pattern]).extra_files }
            .to raise_error(Boondoc::Error, /outside the project/)
        end
      end
    end

    it "refuses extra files that are symlinks to outside the project" do
      with_sandbox do |project, outside|
        File.symlink(secret(outside), File.join(project, "link.md"))
        config = described_class.new(root: project, files: ["*.md"])
        expect { config.extra_files }.to raise_error(Boondoc::Error, /outside the project/)
      end
    end

    it "accepts an absolute path inside the project, relative to the root" do
      with_sandbox do |project, _|
        File.write(File.join(project, "GUIDE.md"), "# Guide")
        config = described_class.new(root: project, files: [File.join(project, "*.md")])
        expect(config.extra_files).to eq(["GUIDE.md"])
      end
    end
  end

  describe "the output directory" do
    include_context "with a sandbox"

    def output_dir_for(**options)
      described_class.new(root: project, **options).output_dir
    end

    it "refuses an output directory outside the project", :aggregate_failures do
      [outside, "../outside", "~/boondoc-docs"].each do |path|
        expect { output_dir_for(output: path) }
          .to raise_error(Boondoc::Error, /outside the project.*--allow-outside-output/m)
      end
    end

    it "allows an output directory outside the project when asked to" do
      expect(output_dir_for(output: outside, allow_outside_output: true)).to eq(outside)
    end

    it "accepts an output directory inside the project, even if it does not exist yet" do
      expect(output_dir_for(output: "api/docs")).to eq(File.join(project, "api", "docs"))
    end

    [{}, { allow_outside_output: true }].each do |options|
      it "refuses an output directory that is a symlink (#{options})" do
        File.symlink(outside, File.join(project, "docs"))
        expect { output_dir_for(**options) }.to raise_error(Boondoc::Error, /symlink/)
      end
    end

    it "refuses an output directory below a symlink" do
      File.symlink(outside, File.join(project, "site"))
      expect { output_dir_for(output: "site/docs") }.to raise_error(Boondoc::Error, /symlink/)
    end

    it "does not let .boondoc.yml move the output outside the project" do
      File.write(File.join(project, ".boondoc.yml"), "output: #{outside}\nforce: true\n")
      config = described_class.load({}, root: project)
      expect { config.output_dir }.to raise_error(Boondoc::Error, /outside the project/)
    end

    it "does not let .boondoc.yml allow an outside output directory" do
      File.write(File.join(project, ".boondoc.yml"), "allow_outside_output: true\n")
      expect { described_class.load({}, root: project) }
        .to raise_error(Boondoc::Error, /allow_outside_output.*command line/m)
    end

    it "takes allow_outside_output from the overrides" do
      config = described_class.load({ output: outside, allow_outside_output: true }, root: project)
      expect(config.output_dir).to eq(outside)
    end
  end

  describe "source files outside the project" do
    include_context "with a sandbox"

    let!(:secret) { File.join(outside, "secret.rb").tap { |path| File.write(path, "TOKEN = 'hunter2'\n") } }

    def config_for(**options)
      described_class.new(root: project, **options)
    end

    it "leaves out sources named by absolute path or by ../", :aggregate_failures do
      config = config_for(sources: [secret, "../outside/*.rb"])
      expect(config.source_files).to be_empty
      expect(config.outside_sources).to contain_exactly(secret, "../outside/secret.rb")
    end

    it "leaves out a source that is a symlink to a file outside the project", :aggregate_failures do
      File.symlink(secret, File.join(project, "lib", "settings.rb"))
      expect(config_for.source_files).to be_empty
      expect(config_for.outside_sources).to eq(["lib/settings.rb"])
    end

    it "leaves out sources below a symlinked directory", :aggregate_failures do
      File.symlink(outside, File.join(project, "lib", "shared"))
      config = config_for(sources: ["lib/shared/*.rb"])
      expect(config.source_files).to be_empty
      expect(config.outside_sources).to eq(["lib/shared/secret.rb"])
    end
  end

  describe "option types" do
    {
      private: "no", protected: 1, strict: "true", force: nil, quiet: [], yard_macros: "yes",
      allow_outside_output: "yes", sources: 3, exclude: [1], files: {}, output: ["docs"], index: 5,
      title: 3, readme: 5
    }.each do |key, value|
      it "rejects #{value.inspect} for #{key}" do
        expect { described_class.new(key => value) }
          .to raise_error(Boondoc::Error, /option `#{key}` must be .+ \(got #{Regexp.escape(value.inspect)}\)/)
      end
    end

    it "accepts every default and the documented alternatives", :aggregate_failures do
      expect { described_class.new }.not_to raise_error
      expect { described_class.new(sources: "lib", files: ["a.md"], readme: false, title: nil) }.not_to raise_error
      expect { described_class.new(readme: "README.md", title: "T", private: true) }.not_to raise_error
    end

    it "rejects a wrong type in .boondoc.yml" do
      with_sandbox do |project, _|
        File.write(File.join(project, ".boondoc.yml"), "private: \"no\"\n")
        expect { described_class.load({}, root: project) }
          .to raise_error(Boondoc::Error, /option `private` must be true or false \(got "no"\)/)
      end
    end

    it "still lets a nil override fall back to the file and the defaults" do
      with_sandbox do |project, _|
        expect(described_class.load({ strict: nil, title: nil }, root: project)).to have_attributes(strict: false)
      end
    end
  end

  describe ".yardopts" do
    include_context "with a sandbox"

    def write(name, text)
      File.write(File.join(project, name), text)
    end

    def load_config(overrides = {})
      described_class.load(overrides, root: project)
    end

    before do
      FileUtils.mkdir_p(File.join(project, "src"))
      %w[lib/a.rb lib/legacy.rb src/b.rb].each { |path| File.write(File.join(project, path), "class A; end\n") }
      write("CHANGELOG.md", "# Changes\n")
      write(".yardopts", "--title Yard --exclude legacy -o doc --markup markdown src - CHANGELOG.md\n")
    end

    it "takes sources, files, title, and exclusions from .yardopts", :aggregate_failures do
      config = load_config
      expect(config).to have_attributes(title: "Yard", source_files: ["src/b.rb"], extra_files: ["CHANGELOG.md"])
    end

    it "never takes the output directory from .yardopts", :aggregate_failures do
      config = load_config
      expect(config.output_dir).to eq(File.join(project, "docs"))
      expect(config.yardopts_notes.first).to include("ignoring --output-dir doc")
    end

    it "lets .boondoc.yml and then the overrides win, key by key", :aggregate_failures do
      write(".boondoc.yml", "title: Yml\nsources: lib\nexclude: []\n")
      expect(load_config).to have_attributes(
        title: "Yml",
        source_files: %w[lib/a.rb lib/legacy.rb],
        extra_files: ["CHANGELOG.md"]
      )
      expect(load_config(title: "Flag")).to have_attributes(title: "Flag")
    end

    it "is skipped by yardopts: false and by the override", :aggregate_failures do
      write(".boondoc.yml", "yardopts: false\n")
      expect(load_config).to have_attributes(title: File.basename(project), extra_files: [], yardopts_notes: [])
      File.delete(File.join(project, ".boondoc.yml"))
      expect(load_config(yardopts: false)).to have_attributes(extra_files: [], source_files: %w[lib/a.rb lib/legacy.rb])
    end

    it "applies the same containment rules as .boondoc.yml", :aggregate_failures do
      File.write(File.join(outside, "secret.md"), "secret")
      write(".yardopts", "lib - #{File.join(outside, "secret.md")}\n")
      expect { load_config.extra_files }.to raise_error(Boondoc::Error, /outside the project/)
      write(".yardopts", "#{File.join(outside, "*.rb")}\n")
      expect(load_config.source_files).to eq([])
    end
  end

  describe ".load" do
    def load_with_file(overrides)
      with_project("sample") do |dir|
        File.write(File.join(dir, ".boondoc.yml"), "output: api\nprivate: true\nfiles:\n  - guides/*.md\n")
        yield described_class.load(overrides, root: dir)
      end
    end

    it "merges the config file under explicit overrides" do
      load_with_file(output: "elsewhere", strict: nil) do |config|
        expect(config).to have_attributes(
          output: "elsewhere",
          private: true,
          strict: false,
          extra_files: ["guides/intro.md"]
        )
      end
    end

    it "raises when a named config file is missing" do
      expect { described_class.load({ config: "nope.yml" }, root: fixture_root("sample")) }
        .to raise_error(Boondoc::Error, /config file not found/)
    end
  end
end
