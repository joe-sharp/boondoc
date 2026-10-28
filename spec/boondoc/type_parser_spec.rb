# frozen_string_literal: true

RSpec.describe Boondoc::TypeParser do
  describe ".extract" do
    it "returns the types and the remaining text" do
      expect(described_class.extract("[String, nil] the name")).to eq([%w[String nil], "the name"])
    end

    it "keeps nested generics and hash rockets together", :aggregate_failures do
      types, rest = described_class.extract("[Hash{Symbol => Array<Integer>}, #to_s] rest")
      expect(types).to eq(["Hash{Symbol => Array<Integer>}", "#to_s"])
      expect(rest).to eq("rest")
    end

    it "does not treat angle brackets in operator duck types as nesting", :aggregate_failures do
      expect(described_class.extract("[#<=>, #<<] other")).to eq([["#<=>", "#<<"], "other"])
      expect(described_class.extract("[#>=, #[]] other")).to eq([["#>=", "#[]"], "other"])
    end

    it "returns nil types when the text does not start with a bracket" do
      expect(described_class.extract("just text")).to eq([nil, "just text"])
    end

    it "returns nil types when the bracket never closes" do
      expect(described_class.extract("[String oops")).to eq([nil, "[String oops"])
    end
  end
end
