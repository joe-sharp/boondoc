# frozen_string_literal: true

RSpec.describe Boondoc::DocstringParser do
  def parse(text)
    described_class.parse(text)
  end

  it "separates the body from the tags", :aggregate_failures do
    docstring = parse("Does a thing.\n\nMore detail.\n@return [String] the result")
    expect(docstring.text).to eq("Does a thing.\n\nMore detail.")
    expect(docstring.tags.map(&:tag_name)).to eq(["return"])
  end

  it "parses @param in both orders", :aggregate_failures do
    name_first = parse("@param name [String] the name").tag("param")
    type_first = parse("@param [String] name the name").tag("param")
    expect(name_first.to_h).to include(name: "name", types: ["String"], text: "the name")
    expect(type_first.to_h).to include(name: "name", types: ["String"], text: "the name")
  end

  it "joins indented continuation lines into the tag" do
    tag = parse("@return [String] first line\n  second line\nBody text").tag("return")
    expect(tag.text).to eq("first line\nsecond line")
  end

  it "returns unindented text after a tag to the body" do
    expect(parse("@return [String] x\nBody text").text).to eq("Body text")
  end

  it "parses @option with a key and default" do
    tag = parse("@option opts [Integer] :retries (3) how many times").tag("option")
    expect(tag.to_h).to include(name: "opts", key: ":retries", default: "3", types: ["Integer"],
                                text: "how many times")
  end

  it "parses @example with a title and dedented code", :aggregate_failures do
    tag = parse("@example Greeting\n  puts 'hi'\n    indented").tag("example")
    expect(tag.name).to eq("Greeting")
    expect(tag.text).to eq("puts 'hi'\n  indented")
  end

  it "parses @overload with a nested docstring", :aggregate_failures do
    tag = parse("@overload call(a, b)\n  Adds.\n  @param a [Integer]\n  @return [Integer]").tag("overload")
    expect(tag.signature).to eq("call(a, b)")
    expect(tag.docstring.text).to eq("Adds.")
    expect(tag.docstring.tags.map(&:tag_name)).to eq(%w[param return])
  end

  it "parses @see into a reference and a description" do
    tag = parse("@see Foo#bar the other one").tag("see")
    expect(tag.to_h).to include(name: "Foo#bar", text: "the other one")
  end

  it "records directives separately from tags", :aggregate_failures do
    docstring = parse("@!macro foo\n@return [String]")
    expect(docstring.directives).to eq(["macro"])
    expect(docstring.tags.map(&:tag_name)).to eq(["return"])
  end

  it "does not treat @ lines inside a fenced block as tags", :aggregate_failures do
    docstring = parse("Example:\n\n```ruby\n@name = 1\n```")
    expect(docstring.tags).to be_empty
    expect(docstring.text).to include("@name = 1")
  end

  describe "summary" do
    it "is the first sentence of the first paragraph" do
      expect(parse("First sentence. Second one.\n\nNext paragraph.").summary).to eq("First sentence.")
    end

    it "falls back to the return description" do
      expect(parse("@return [String] the name").summary).to eq("Returns the name")
    end
  end
end
