# frozen_string_literal: true

RSpec.describe Boondoc::Renderer::Index do
  include_context "with a sandbox"

  def index(source, **options)
    File.write(File.join(project, "lib", "a.rb"), source)
    config = Boondoc::Config.new(root: project, readme: false, title: "My API", **options)
    generator = Boondoc::Generator.new(config, reporter: quiet_reporter)
    generator.parse(config.source_files)
    generator.render.fetch("README.md")
  end

  it "starts with the title when there is no README" do
    expect(index("class Foo; end\n")).to start_with("# My API\n")
  end

  it "lists the API with summaries", :aggregate_failures do
    page = index("# The foo.\nclass Foo\n  # Inner.\n  class Bar; end\nend\n")
    expect(page).to include("## API reference")
    expect(page).to include("- [`Foo`](Foo.md) — The foo.\n  - [`Foo::Bar`](Foo/Bar.md) — Inner.")
  end

  it "links the top level only when top-level.md has content", :aggregate_failures do
    expect(index("def helper; end\nclass Foo; end\n")).to include("- [Top level](top-level.md)")
    expect(index("class Foo; end\n")).not_to include("Top level")
  end

  it "lists stitched files under Files with their titles", :aggregate_failures do
    File.write(File.join(project, "GUIDE.md"), "# Getting started\n\nHello.\n")
    page = index("class Foo; end\n", files: ["GUIDE.md"])
    expect(page).to include("## Files\n\n- [Getting started](files/GUIDE.md)")
  end

  it "has no Files section without extra files" do
    expect(index("class Foo; end\n")).not_to include("## Files")
  end
end
