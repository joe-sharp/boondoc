# frozen_string_literal: true

RSpec.describe Boondoc::Reporter do
  let(:io) { StringIO.new }

  it "records a warning and prints it", :aggregate_failures do
    reporter = described_class.new(io: io)
    reporter.warn("careful")
    expect(reporter.warnings).to eq(["careful"])
    expect(io.string).to eq("warning: careful\n")
  end

  it "ignores a repeated warning", :aggregate_failures do
    reporter = described_class.new(io: io)
    2.times { reporter.warn("careful") }
    expect(reporter.warnings).to eq(["careful"])
    expect(io.string.lines.size).to eq(1)
  end

  it "prints informational messages unless quiet" do
    described_class.new(io: io).info("done")
    expect(io.string).to eq("done\n")
  end

  it "hides informational messages but not warnings when quiet", :aggregate_failures do
    reporter = described_class.new(io: io, quiet: true)
    reporter.info("done")
    reporter.warn("careful")
    expect(io.string).to eq("warning: careful\n")
    expect(reporter.warnings).to eq(["careful"])
  end
end
