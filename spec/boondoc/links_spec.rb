# frozen_string_literal: true

RSpec.describe Boondoc::Links do
  # Records each path it is given, as "target (embedded or linked)", and returns it unchanged.
  def seen(content)
    found = []
    described_class.rewrite(content) do |target, embedded|
      found << "#{target} (#{embedded ? "embedded" : "linked"})"
      target
    end
    found
  end

  it "marks images, video, and <source> as embedded, and plain links as linked", :aggregate_failures do
    expect(seen("![a](a.png) [b](b.md)\n")).to eq(["a.png (embedded)", "b.md (linked)"])
    expect(seen(%(<img src="c.png"> <a href="d.md">x</a> <video poster="e.png">\n))).to eq(
      ["c.png (embedded)", "d.md (linked)", "e.png (embedded)"]
    )
  end

  it "marks a reference definition as embedded only when an image uses it", :aggregate_failures do
    content = "![alt][logo]\n\n[text][page]\n\n[logo]: a.png\n[page]: b.md\n"
    expect(seen(content)).to eq(["a.png (embedded)", "b.md (linked)"])
  end

  it "reads every candidate of a srcset as embedded" do
    expect(seen(%(<source srcset="a.png 1x, b.png 2x">))).to eq(["a.png (embedded)", "b.png (embedded)"])
  end

  it "tells an image from a link that starts right after an image", :aggregate_failures do
    expect(seen("![a [nested] b](img.png) [c](page.md)\n")).to eq(["img.png (embedded)", "page.md (linked)"])
  end

  it "leaves external targets and code alone", :aggregate_failures do
    content = "![x](https://example.com/a.png) `![y](z.png)`\n\n```\n![w](v.png)\n```\n"
    expect(seen(content)).to eq([])
  end

  it "writes the rewritten target back in place" do
    rewritten = described_class.rewrite("![a](old.png \"title\")\n") { |target, _| target.sub("old", "new") }
    expect(rewritten).to eq("![a](new.png \"title\")\n")
  end
end
