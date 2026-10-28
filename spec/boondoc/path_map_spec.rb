# frozen_string_literal: true

RSpec.describe Boondoc::PathMap do
  include_context "with a sandbox"

  let(:registry) do
    parse_source(<<~RUBY)
      def helper; end
      class Foo
        MAX = 1
        def self.build; end
        def save?; end
        class Bar; end
      end
    RUBY
  end
  let(:map) { described_class.new(Boondoc::Config.new(root: project), registry) }

  describe "#file_for" do
    it "mirrors nested namespaces as directories", :aggregate_failures do
      expect(map.file_for(registry["Foo"])).to eq("Foo.md")
      expect(map.file_for(registry["Foo::Bar"])).to eq("Foo/Bar.md")
    end

    it "puts members in the file of their namespace", :aggregate_failures do
      expect(map.file_for(registry["Foo#save?"])).to eq("Foo.md")
      expect(map.file_for(registry["Foo::MAX"])).to eq("Foo.md")
    end

    it "puts the top level in top-level.md", :aggregate_failures do
      expect(map.file_for(registry[""])).to eq("top-level.md")
      expect(map.file_for(registry["#helper"])).to eq("top-level.md")
    end
  end

  describe "#file_for with names that differ only by case" do
    let(:registry) do
      parse_source(<<~RUBY)
        module Guard
          class CLI; end
          module Cli
            module Environments
              class Valid; end
            end
          end
          class Plain; end
        end
        module Same
          class Dup; end
          class DUP; end
          class DuP; end
        end
        class Foo; class X; end; end
        class FOO; class X; end; end
      RUBY
    end

    it "appends the kind to both files", :aggregate_failures do
      expect(map.file_for(registry["Guard::CLI"])).to eq("Guard/CLI.class.md")
      expect(map.file_for(registry["Guard::Cli"])).to eq("Guard/Cli.module.md")
    end

    it "leaves other names alone" do
      expect(map.file_for(registry["Guard::Plain"])).to eq("Guard/Plain.md")
    end

    it "puts the children of a renamed namespace in its directory", :aggregate_failures do
      expect(map.file_for(registry["Guard::Cli::Environments"])).to eq("Guard/Cli.module/Environments.md")
      expect(map.file_for(registry["Guard::Cli::Environments::Valid"]))
        .to eq("Guard/Cli.module/Environments/Valid.md")
    end

    it "numbers namespaces of the same kind", :aggregate_failures do
      expect(map.file_for(registry["Same::DUP"])).to eq("Same/DUP.class.md")
      expect(map.file_for(registry["Same::DuP"])).to eq("Same/DuP.class-2.md")
      expect(map.file_for(registry["Same::Dup"])).to eq("Same/Dup.class-3.md")
    end

    it "does not rename children of colliding parents once the parents are apart", :aggregate_failures do
      expect(map.file_for(registry["Foo::X"])).to eq("Foo.class-2/X.md")
      expect(map.file_for(registry["FOO::X"])).to eq("FOO.class/X.md")
    end

    it "never produces paths that collide on a case-insensitive filesystem" do
      paths = registry.grep(Boondoc::Model::NamespaceObject).map { |ns| map.file_for(ns) }
      expect(paths.uniq.group_by(&:downcase).values.map(&:size).max).to eq(1)
    end
  end

  describe "#anchor_for" do
    it "escapes characters that are not word characters" do
      expect(map.anchor_for(registry["Foo#save?"])).to eq("method-i-save-3F")
    end

    it "tells class methods and constants apart", :aggregate_failures do
      expect(map.anchor_for(registry["Foo.build"])).to eq("method-c-build")
      expect(map.anchor_for(registry["Foo::MAX"])).to eq("constant-MAX")
    end

    it "has no anchor for a namespace" do
      expect(map.anchor_for(registry["Foo"])).to be_nil
    end
  end

  describe "#href" do
    it "links within the same file by anchor only" do
      expect(map.href(registry["Foo#save?"], from: "Foo.md")).to eq("#method-i-save-3F")
    end

    it "links to another file relative to the current one", :aggregate_failures do
      expect(map.href(registry["Foo#save?"], from: "Foo/Bar.md")).to eq("../Foo.md#method-i-save-3F")
      expect(map.href(registry["Foo::Bar"], from: "README.md")).to eq("Foo/Bar.md")
    end
  end

  describe "#relative" do
    it "encodes spaces" do
      expect(map.relative("files/my guide.md", "README.md")).to eq("files/my%20guide.md")
    end

    it "works a link out once and hands back the same string" do
      expect(map.relative("Foo/Bar.md", "Foo.md")).to equal(map.relative("Foo/Bar.md", "Foo.md"))
    end
  end

  describe "#source_href" do
    it "links from an output file back to a project file, encoding spaces" do
      expect(map.source_href("lib/my file.rb", from: "Foo/Bar.md")).to eq("../../lib/my%20file.rb")
    end
  end
end
