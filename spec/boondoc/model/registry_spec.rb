# frozen_string_literal: true

RSpec.describe Boondoc::Model::Registry do
  let(:registry) do
    parse_source(<<~RUBY)
      module App
        LIMIT = 1
        module Helpers
          def assist; end
        end
        class Base
          include Helpers
          def run; end
          def self.build; end
        end
        class Worker < Base
          # (see Base#run)
          def perform; end
          def []=(key, value); end
        end
      end
      class Other; end
    RUBY
  end

  it "lists each file with directives once, in order" do
    registry.directive_sites.push("lib/b.rb:3", "lib/b.rb:9", "lib/a.rb:1")
    expect(registry.directive_files).to eq(%w[lib/b.rb lib/a.rb])
  end

  def resolve(context, reference)
    registry.resolve(registry[context], reference)&.path
  end

  it "resolves constants through enclosing namespaces", :aggregate_failures do
    expect(resolve("App::Worker", "Base")).to eq("App::Base")
    expect(resolve("App::Worker#perform", "Other")).to eq("Other")
    expect(resolve("App::Worker", "LIMIT")).to eq("App::LIMIT")
    expect(resolve("App::Worker", "::App::Base")).to eq("App::Base")
  end

  it "resolves methods with explicit separators", :aggregate_failures do
    expect(resolve("Other", "App::Base#run")).to eq("App::Base#run")
    expect(resolve("Other", "App::Base.build")).to eq("App::Base.build")
    expect(resolve("Other", "App::Base::build")).to eq("App::Base.build")
    expect(resolve("App::Worker", "#[]=")).to eq("App::Worker#[]=")
  end

  it "resolves bare and relative method names from the current namespace", :aggregate_failures do
    expect(resolve("App::Worker#perform", "#perform")).to eq("App::Worker#perform")
    expect(resolve("App::Worker#perform", "perform")).to eq("App::Worker#perform")
  end

  it "finds methods on superclasses and mixins", :aggregate_failures do
    expect(resolve("App::Worker", "#run")).to eq("App::Base#run")
    expect(resolve("Other", "App::Worker#assist")).to eq("App::Helpers#assist")
    expect(resolve("App::Worker", ".build")).to eq("App::Base.build")
  end

  it "returns nil for anything unknown", :aggregate_failures do
    expect(resolve("Other", "Nope")).to be_nil
    expect(resolve("Other", "App::Base#nope")).to be_nil
    expect(resolve("Other", "")).to be_nil
  end

  it "lists ancestors nearest first" do
    expect(registry.ancestors(registry["App::Worker"]).map(&:path)).to eq(%w[App::Worker App::Base App::Helpers])
  end

  it "resolves a superclass from the enclosing scope, not the class itself", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class Error; end
      class Base; end
      module M
        class Error < Error; end
        class Child < Base
          class Base; end
        end
      end
    RUBY
    expect(registry.ancestors(registry["M::Error"]).map(&:path)).to eq(%w[M::Error Error])
    expect(registry.ancestors(registry["M::Child"]).map(&:path)).to eq(%w[M::Child Base])
  end

  it "expands chained (see ...) references regardless of definition order", :aggregate_failures do
    registry = parse_source(<<~RUBY)
      class Foo
        # (see #b)
        def a; end
        # (see #c)
        # @return [Integer] the count
        def b; end
        # The real docs.
        # @return [String]
        def c; end
      end
    RUBY
    expect(registry["Foo#a"].docstring.text).to eq("The real docs.")
    expect(registry["Foo#a"].docstring.tag("return").types).to eq(["Integer"])
  end

  it "expands (see ...) references that form a cycle without hanging" do
    registry = parse_source(<<~RUBY)
      class Foo
        # (see #b)
        def a; end
        # (see #a)
        def b; end
      end
    RUBY
    expect(registry["Foo#a"].docstring.text).to match(/\A\(see #[ab]\)\z/)
  end

  describe "(see ...)" do
    let(:registry) do
      parse_source(<<~RUBY)
        class Base
          # Runs it.
          # @param times [Integer]
          # @return [Boolean]
          def run(times); end
        end
        class Child < Base
          # (see Base#run)
          # @return [nil] overridden
          def run(times); end

          # @param times (see Base#run)
          def again(times); end
        end
      RUBY
    end

    it "copies referenced docstrings", :aggregate_failures do
      child = registry["Child#run"].docstring
      expect(child.text).to eq("Runs it.")
      expect(child.tag("return").types).to eq(["nil"])
      expect(child.tag("param").name).to eq("times")
      expect(registry["Child#again"].docstring.tag("param").types).to eq(["Integer"])
    end
  end
end
