# frozen_string_literal: true

require "timeout"

RSpec.describe Boondoc::References do
  def docstring(registry, path)
    registry[path].docstring
  end

  it "copies the text and tags of a referenced method", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class A
        # Does the thing.
        # @param x [Integer] the x
        def one(x); end

        # (see #one)
        def two(x); end
      end
    RUBY
    expect(docstring(registry, "A#two").text).to eq("Does the thing.")
    expect(docstring(registry, "A#two").tags_named("param").map(&:text)).to eq(["the x"])
  end

  it "keeps the tags that the referring method has of its own" do
    registry = parse_source(<<~RUBY)
      class A
        # @param x [Integer] from one
        # @return [String] from one
        def one(x); end

        # (see #one)
        # @return [Symbol] own
        def two(x); end
      end
    RUBY
    expect(docstring(registry, "A#two").tags_named("return").map(&:text)).to eq(["own"])
  end

  it "expands the text of a single tag" do
    registry = parse_source(<<~RUBY)
      class A
        # @param name [String] the name to use
        def one(name); end

        # @param name (see #one)
        def two(name); end
      end
    RUBY
    expect(docstring(registry, "A#two").tags_named("param").map(&:text)).to eq(["the name to use"])
  end

  it "follows chains whichever order they are defined in" do
    registry = parse_source(<<~RUBY)
      class A
        # (see #b)
        def c; end

        # (see #a)
        def b; end

        # The original.
        def a; end
      end
    RUBY
    expect(docstring(registry, "A#c").text).to eq("The original.")
  end

  it "terminates when references form a cycle" do
    source = <<~RUBY
      class A
        # (see #b)
        def a; end

        # (see #a)
        def b; end
      end
    RUBY
    expect { Timeout.timeout(5) { parse_source(source) } }.not_to raise_error
  end

  it "leaves a reference that does not resolve as it is" do
    registry = parse_source("class A\n  # (see #missing)\n  def a; end\nend\n")
    expect(docstring(registry, "A#a").text).to eq("(see #missing)")
  end

  it "ignores an object that refers to itself" do
    registry = parse_source("class A\n  # (see #a)\n  def a; end\nend\n")
    expect(docstring(registry, "A#a").text).to eq("(see #a)")
  end
end
