# frozen_string_literal: true

require 'boondoc/rake_task'

RSpec.describe Boondoc::RakeTask do
  let(:generator) { instance_double(Boondoc::Generator, run: nil) }
  let(:configs) { [] }
  let(:outside) { Dir.mktmpdir('boondoc') }

  before do
    Rake::Task.clear
    allow(Boondoc::Generator).to receive(:new) do |config|
      configs << config
      generator
    end
  end

  after do
    Rake::Task.clear
    FileUtils.rm_rf(outside)
  end

  it 'defines a task called docs by default' do
    described_class.new
    expect(Rake::Task.task_defined?(:docs)).to be(true)
  end

  it 'defines the task under the name it is given' do
    described_class.new(:api_docs)
    expect(Rake::Task.task_defined?(:api_docs)).to be(true)
  end

  it 'builds a config from the options and runs the generator', :aggregate_failures do
    described_class.new(:docs) { |task| task.options = { strict: true, title: 'Mine' } }
    Rake::Task[:docs].invoke
    expect(configs.first).to have_attributes(strict: true, title: 'Mine')
    expect(generator).to have_received(:run)
  end

  it 'passes allow_outside_output through, since Rake options are the caller\'s', :aggregate_failures do
    described_class.new(:docs) { |task| task.options = { output: outside, allow_outside_output: true } }
    Rake::Task[:docs].invoke
    expect(configs.first.allow_outside_output).to be(true)
    expect(configs.first.output_dir).to eq(outside)
  end
end
