# frozen_string_literal: true

RSpec.describe Boondoc::Assets do
  include_context "with a sandbox"

  def write(path, content = "bytes")
    File.join(project, path).tap do |full|
      FileUtils.mkdir_p(File.dirname(full))
      File.write(full, content)
    end
  end

  # The files chosen, with project paths relative to the project.
  def select(*entries)
    described_class.new(Boondoc::Config.new(root: project, assets: entries)).files
      .transform_values { |path| path.delete_prefix("#{project}/") }
  end

  it "copies a file to its project path, and a directory recursively", :aggregate_failures do
    write("images/a.png")
    write("images/deep/b.svg")
    expect(select("images/a.png")).to eq("images/a.png" => "images/a.png")
    expect(select("images")).to eq("images/a.png" => "images/a.png", "images/deep/b.svg" => "images/deep/b.svg")
  end

  it "copies into the directory named after the colon" do
    write("images/a.png")
    expect(select("images:media")).to eq("media/a.png" => "images/a.png")
  end

  it "skips hidden files and anything in the output directory" do
    write("images/.secret.png")
    write("images/a.png")
    write("docs/copied.png")
    expect(select("images", "docs")).to eq("images/a.png" => "images/a.png")
  end

  it "refuses a file outside the project, including through a symlink", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    outside_file = File.join(outside, "secret.png")
    File.write(outside_file, "x")
    write("images/a.png")
    File.symlink(outside_file, File.join(project, "images/evil.png"))
    expect { select(outside_file) }.to raise_error(Boondoc::Error, /outside the project/)
    expect(select("images")).to eq("images/a.png" => "images/a.png")
  end

  it "refuses a destination that leaves the output directory" do
    write("images/a.png")
    expect { select("images:../../x") }.to raise_error(Boondoc::Error, /outside the output directory/)
  end

  it "refuses two different files copied to the same path" do
    write("images/a.png")
    write("guides/a.png")
    expect { select("images/a.png:media", "guides/a.png:media") }
      .to raise_error(Boondoc::Error, /would be copied from both/)
  end

  it "accepts the same file named twice" do
    write("images/a.png")
    expect(select("images/a.png", "images")).to eq("images/a.png" => "images/a.png")
  end
end
