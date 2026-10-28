# frozen_string_literal: true

RSpec.describe Boondoc::Generator do
  let(:options) { { files: ["guides/*.md"] } }
  let(:rendered) { render_fixture("sample", **options) }
  let(:pages) { rendered.first }
  let(:reporter) { rendered.last }
  let(:expected_dir) { File.join(fixture_root("sample"), "expected") }

  # Regenerate with: UPDATE_GOLDEN=1 bundle exec rspec spec/boondoc/generator_spec.rb
  before do
    next unless ENV["UPDATE_GOLDEN"]

    FileUtils.rm_rf(expected_dir)
    pages.each do |path, content|
      FileUtils.mkdir_p(File.dirname(File.join(expected_dir, path)))
      File.write(File.join(expected_dir, path), content)
    end
  end

  it "renders the same set of files as the golden output" do
    golden = Dir.glob("**/*.md", base: expected_dir).sort
    expect(pages.keys.sort).to eq(golden)
  end

  it "matches the golden output for every page" do
    pages.each do |path, content|
      expect(content).to eq(File.read(File.join(expected_dir, path))), "#{path} differs from the golden file"
    end
  end

  def broken_links(path, content)
    content.scan(/\]\(([^)\s]+)\)/).flatten.filter_map do |target|
      file, anchor = target.split("#", 2)
      next if external_link?(target, file)

      page = link_target_page(path, file)
      next if page.start_with?("../")

      "#{path} -> #{target}" unless link_exists?(page, anchor)
    end
  end

  def external_link?(target, file)
    target.match?(%r{\A[a-z]+://}) || (file.start_with?("../") && !file.end_with?(".md"))
  end

  def link_exists?(page, anchor)
    pages.key?(page) && (anchor.nil? || pages[page].include?(%(id="#{anchor}")))
  end

  def link_target_page(path, file)
    return path if file.empty?

    Pathname.new(File.join(File.dirname(path), file)).cleanpath.to_s
  end

  it "only links to pages and anchors that exist" do
    broken = pages.flat_map { |path, content| broken_links(path, content) }
    expect(broken).to eq([])
  end

  it "warns once about each unresolved reference" do
    expect(reporter.warnings).to eq(["Sample::Circle.unit: cannot resolve link to Missing::Thing"])
  end

  it "hides private and protected objects by default", :aggregate_failures do
    expect(pages.keys).not_to include("Sample/Internal.md")
    expect(pages["Sample/Shape.md"]).not_to include("#kind", "#helper")
    expect(pages["Sample/Circle.md"]).not_to include(".hidden")
  end

  context "with private: true" do
    let(:options) { { private: true } }

    it "includes private, protected and @private objects", :aggregate_failures do
      expect(pages.keys).to include("Sample/Internal.md")
      expect(pages["Sample/Shape.md"]).to include("`#kind`", "`#helper`", "- **Visibility:** private")
      expect(pages["Sample/Circle.md"]).to include("`.hidden`")
    end
  end

  context "with protected: true" do
    let(:options) { { protected: true } }

    it "includes protected methods only", :aggregate_failures do
      expect(pages["Sample/Shape.md"]).to include("`#kind`")
      expect(pages["Sample/Shape.md"]).not_to include("`#helper`")
    end
  end

  context "without a README" do
    let(:options) { { readme: false, title: "My API" } }

    it "titles the index page and lists the API" do
      expect(pages["README.md"]).to start_with("# My API\n\n## API reference\n")
    end
  end

  context "when the index is given another name" do
    let(:options) { { index: "index.md", files: ["guides/*.md"] } }

    it "writes the index there and points links at it", :aggregate_failures do
      expect(pages.keys).to include("index.md")
      expect(pages["files/guides/intro.md"]).to include("[README](../../index.md)")
    end
  end

  describe "#run" do
    def run(dir, **)
      reporter = quiet_reporter
      described_class.new(Boondoc::Config.new(root: dir, **), reporter: reporter).run
    end

    it "writes the pages and a manifest", :aggregate_failures do
      with_project("sample") do |dir|
        result = run(dir)
        expect(File.read(File.join(dir, "docs", "Sample", "Circle.md"))).to start_with("# Class: Sample::Circle")
        expect(File.readlines(File.join(dir, "docs", ".boondoc-manifest"), chomp: true)).to eq(result.pages)
      end
    end

    it "removes pages for classes that no longer exist", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      with_project("sample") do |dir|
        run(dir)
        File.delete(File.join(dir, "lib", "sample", "util.rb"))
        result = run(dir)
        expect(result.removed).to eq(["Sample/Util.md"])
        expect(File).not_to exist(File.join(dir, "docs", "Sample", "Util.md"))
      end
    end

    context "with images in the README and in doc comments" do
      def write_project(dir)
        File.write(File.join(dir, "README.md"), "# Demo\n\n![logo](images/logo.png)\n\n[see](lib/demo.rb)\n")
        File.write(File.join(dir, "lib", "demo.rb"),
                   "# Doc: ![d](images/logo.png) and [l](images/logo.png)\nclass Demo; end\n")
        FileUtils.mkdir_p(File.join(dir, "images"))
        File.binwrite(File.join(dir, "images", "logo.png"), "\x89PNG".b)
      end

      it "copies the images and points readme and class pages at the copies", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        with_project("sample") do |dir|
          write_project(dir)
          result = run(dir, readme: "README.md", assets: ["images"])
          expect(result.assets).to include("images/logo.png")
          expect(File.binread(File.join(dir, "docs", "images", "logo.png"))).to eq("\x89PNG".b)
          expect(File.read(File.join(dir, "docs", "README.md"))).to include("![logo](images/logo.png)")
          expect(File.read(File.join(dir, "docs", "Demo.md"))).to include("![d](images/logo.png)")
        end
      end

      it "copies only what it is told to, unless copy_linked_assets is set", :aggregate_failures do
        with_project("sample") do |dir|
          write_project(dir)
          expect(run(dir, readme: "README.md").assets).to eq([])
          expect(run(dir, readme: "README.md", copy_linked_assets: true).assets).to eq(["images/logo.png"])
        end
      end
    end

    it "raises in strict mode when there are warnings" do
      with_project("sample") do |dir|
        expect { run(dir, strict: true, files: ["guides/*.md"]) }.to raise_error(Boondoc::Error, /1 warning/)
      end
    end

    context "when a source is outside the project" do
      include_context "with a sandbox"

      before do
        File.write(File.join(project, "lib", "ok.rb"), "# Fine.\nclass Ok; end\n")
        File.write(File.join(outside, ".env"), "DB_PASSWORD = 'hunter2'\n")
        File.symlink(File.join(outside, ".env"), File.join(project, "lib", "settings.rb"))
      end

      def docs_text
        Dir.glob("docs/**/*.md", base: project).sum("") { |file| File.read(File.join(project, file)) }
      end

      it "skips it with a warning and keeps its contents out of the docs", :aggregate_failures do
        result = run(project, readme: false)
        expect(result.warnings.first).to include("skipping lib/settings.rb: it is outside the project")
        expect(docs_text).not_to include("hunter2")
      end

      it "fails in strict mode" do
        expect { run(project, readme: false, strict: true) }.to raise_error(Boondoc::Error, /strict mode/)
      end

      it "raises when nothing inside the project is left" do
        expect { run(project, sources: [File.join(outside, ".env")]) }
          .to raise_error(Boondoc::Error, /no Ruby files matched/)
      end
    end

    it "raises when no source files match" do
      with_project("sample") do |dir|
        expect { run(dir, sources: ["nope/**/*.rb"]) }.to raise_error(Boondoc::Error, /no Ruby files matched/)
      end
    end

    it "warns about directives it cannot expand" do
      with_project("macros") do |dir|
        expect(run(dir).warnings.first).to include("rerun with --yard-macros")
      end
    end

    context "with yard_macros" do
      let(:bridge) { instance_double(Boondoc::YardBridge, merge: 0) }

      before { allow(Boondoc::YardBridge).to receive(:new).and_return(bridge) }

      it "does not run YARD when no file uses directives", :aggregate_failures do
        with_project("sample") { |dir| run(dir, yard_macros: true) }
        expect(Boondoc::YardBridge).not_to have_received(:new)
      end

      it "warns that the setting can be disabled when no file uses directives" do
        with_project("sample") do |dir|
          expect(run(dir, yard_macros: true).warnings.first)
            .to include("no YARD macros or directives were found", "disable yard_macros")
        end
      end

      it "gives YARD only the files that use directives" do
        with_project("macros") { |dir| run(dir, yard_macros: true) }
        expect(bridge).to have_received(:merge).with(["lib/macros.rb"], root: anything)
      end
    end
  end
end
