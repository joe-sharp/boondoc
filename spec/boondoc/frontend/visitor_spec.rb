# frozen_string_literal: true

RSpec.describe Boondoc::Frontend::Visitor do
  it "registers nested namespaces with superclasses and docstrings", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      # Outer docs.
      module Outer
        # Inner docs.
        class Inner < Base; end
      end
    RUBY
    expect(registry["Outer"].kind).to eq(:module)
    expect(registry["Outer::Inner"].superclass).to eq("Base")
    expect(registry["Outer::Inner"].docstring.text).to eq("Inner docs.")
  end

  it "handles compact class names and reopened classes" do
    registry = parse_source(<<~RUBY)
      module A; end
      class A::B
        def one; end
      end
      module A
        class B
          def two; end
        end
      end
    RUBY
    expect(registry["A::B"].meths(:instance).map(&:name)).to eq(%w[one two])
  end

  it "records method signatures and scopes", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class Foo
        def self.build(a, b = 1, *rest, key:, **opts, &block); end
        def call; end
        class << self
          def other; end
        end
      end
    RUBY
    expect(registry["Foo.build"].parameters).to eq("a, b = 1, *rest, key:, **opts, &block")
    expect(registry["Foo#call"].parameters).to be_nil
    expect(registry["Foo.other"].scope).to eq(:class)
  end

  it "tracks every form of visibility" do
    registry = parse_source(<<~RUBY)
      class Foo
        def a; end
        def b; end
        def self.c; end
        def self.d; end
        private :a
        private_class_method :c
        private def e; end
        protected
        def f; end
        public
        def g; end
        private_class_method def self.h; end
        class << self
          private
          def i; end
        end
      end
    RUBY
    visibility = registry.grep(Boondoc::Model::MethodObject).to_h { |meth| [meth.path, meth.visibility] }
    expect(visibility).to eq(
      "Foo#a" => :private, "Foo#b" => :public, "Foo.c" => :private, "Foo.d" => :public,
      "Foo#e" => :private, "Foo#f" => :protected, "Foo#g" => :public, "Foo.h" => :private,
      "Foo.i" => :private
    )
  end

  it "keeps initialize public and marks hook methods private", :aggregate_failures do
    registry = parse_source("class Foo\n  def initialize; end\n  def respond_to_missing?(*); end\nend")
    expect(registry["Foo#initialize"].visibility).to eq(:public)
    expect(registry["Foo#respond_to_missing?"].visibility).to eq(:private)
  end

  describe "attributes" do
    let(:registry) do
      parse_source(<<~RUBY)
        class Foo
          # @return [String]
          attr_accessor :name
          attr_reader :a, :b
          attr_writer :c
        end
      RUBY
    end

    it "registers a reader and a writer for attr_accessor", :aggregate_failures do
      expect(registry["Foo#name"].attribute).to eq(:reader)
      expect(registry["Foo#name="].attribute).to eq(:writer)
    end

    it "gives the writer the docstring of the accessor" do
      expect(registry["Foo#name="].docstring.tag("return").types).to eq(["String"])
    end

    it "registers every name given to attr_reader" do
      expect(registry["Foo#b"]).not_to be_nil
    end

    it "registers only a writer for attr_writer", :aggregate_failures do
      expect(registry["Foo#c"]).to be_nil
      expect(registry["Foo#c="].attribute).to eq(:writer)
    end
  end

  it "turns module_function methods into class methods", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      module Util
        def before; end
        module_function :before
        module_function
        def after; end
      end
    RUBY
    expect(registry["Util.before"]).not_to be_nil
    expect(registry["Util#before"]).to be_nil
    expect(registry["Util.after"].visibility).to eq(:public)
  end

  it "keeps a bare module_function in effect after module_function def", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      module Util
        module_function
        module_function def a; end
        def b; end
      end
    RUBY
    expect(registry["Util.a"]).not_to be_nil
    expect(registry["Util.b"]).not_to be_nil
    expect(registry["Util#b"]).to be_nil
  end

  it "applies a visibility wrapped around alias_method to the alias", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class Foo
        def run; end
        private alias_method :helper, :run
        alias_method :also, :run
      end
    RUBY
    expect(registry["Foo#helper"].visibility).to eq(:private)
    expect(registry["Foo#also"].visibility).to eq(:public)
  end

  it "registers aliases with the original docstring", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class Foo
        # Original.
        def one(a); end
        alias two one
        alias_method :three, :one
      end
    RUBY
    expect(registry["Foo#two"].alias_for).to eq("one")
    expect(registry["Foo#three"].docstring.text).to eq("Original.")
    expect(registry["Foo#three"].parameters).to eq("a")
  end

  it "records mixins" do
    registry = parse_source(<<~RUBY)
      class Foo
        include A, B::C
        extend D
        prepend E
        extend self
        class << self
          include F
        end
      end
    RUBY
    expect(registry["Foo"].mixins).to eq(include: %w[A B::C], extend: %w[D F], prepend: ["E"])
  end

  it "registers constants and honours private_constant", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      module Foo
        # Docs.
        LIMIT = 10
        SECRET = 1
        private_constant :SECRET
      end
    RUBY
    expect(registry["Foo::LIMIT"].value).to eq("10")
    expect(registry["Foo::LIMIT"].docstring.text).to eq("Docs.")
    expect(registry["Foo::SECRET"].visibility).to eq(:private)
  end

  it "treats Struct.new, Data.define and Class.new as classes", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      Point = Struct.new(:x, :y) do
        def sum; end
      end
      Pair = Data.define(:left, :right)
      Failure = Class.new(StandardError)
    RUBY
    expect(registry["Point"].superclass).to eq("Struct")
    expect(registry["Point"].meths(:instance).map(&:name)).to eq(%w[sum x x= y y=])
    expect(registry["Pair"].meths(:instance).map(&:name)).to eq(%w[left right])
    expect(registry["Failure"].superclass).to eq("StandardError")
  end

  it "registers define_method with a literal name", :aggregate_failures do
    registry = parse_source("class Foo\n  # Docs.\n  define_method(:bar) { |a, b| }\nend")
    expect(registry["Foo#bar"].parameters).to eq("a, b")
    expect(registry["Foo#bar"].docstring.text).to eq("Docs.")
  end

  it "does not look inside method bodies", :aggregate_failures do
    registry = parse_source("class Foo\n  def a\n    def b; end\n    X = 1\n  end\nend")
    expect(registry["Foo#b"]).to be_nil
    expect(registry["Foo::X"]).to be_nil
  end

  it "skips definitions marked :nodoc:" do
    registry = parse_source("class Foo\n  def a; end # :nodoc:\n  def b; end\nend")
    expect(registry["Foo"].meths(:instance).map(&:name)).to eq(["b"])
  end

  it "only attaches comments that sit directly above a definition", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      # frozen_string_literal: true

      # Not attached.

      class Foo
        x = 1 # trailing
        # rubocop:disable Some/Cop
        # Attached.
        def a; end
      end
    RUBY
    expect(registry["Foo"].docstring).to be_empty
    expect(registry["Foo#a"].docstring.text).to eq("Attached.")
  end

  it "collects top-level methods on the root" do
    registry = parse_source("# Helper.\ndef helper(a); end")
    expect(registry["#helper"].docstring.text).to eq("Helper.")
  end

  it "warns about and skips files with syntax errors", :aggregate_failures do
    reporter = quiet_reporter
    registry = parse_source("class Foo def", reporter: reporter)
    expect(registry.count).to eq(1)
    expect(reporter.warnings.first).to include("syntax error")
  end

  it "notes comments that use directives" do
    registry = parse_source("class Foo\n  # @!method bar\n  #   Docs.\nend")
    expect(registry.directive_sites).to eq(["test.rb:3"])
  end
end
