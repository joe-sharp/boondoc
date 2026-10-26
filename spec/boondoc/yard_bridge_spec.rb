# frozen_string_literal: true

RSpec.describe Boondoc::YardBridge do
  context 'when yard is available', :yard do
    let(:config) { Boondoc::Config.new(root: fixture_root('macros'), yard_macros: true) }
    let(:rendered) { render_fixture('macros', yard_macros: true) }
    let(:page) { rendered.first['Settings.md'] }

    it 'adds methods created by an attached macro', :aggregate_failures do
      expect(page).to include('### <a id="method-i-timeout"></a>`#timeout`', 'The timeout setting.', '- (`Integer`)')
      expect(page).to include('The label setting.')
    end

    it 'adds attributes declared with @!attribute' do
      expect(page).to include("```ruby\nattr_reader :source\n```", 'where the settings were loaded from')
    end

    it 'leaves objects Prism already found untouched' do
      expect(page).to include("```ruby\ndef to_h\n```\n\nA regular method.")
    end

    it 'does not warn about directives' do
      expect(rendered.last.warnings).to be_empty
    end

    it 'records files relative to the project without changing directory', :aggregate_failures do
      allow(Dir).to receive(:chdir).and_call_original
      generator = Boondoc::Generator.new(config, reporter: quiet_reporter)
      generator.parse(config.source_files)
      expect(Dir).not_to have_received(:chdir)
      expect(generator.registry['Settings#timeout'].files).to eq([['lib/macros.rb', 11]])
    end
  end

  context 'when yard is not installed' do
    it 'raises a helpful error' do
      bridge = described_class.new(Boondoc::Model::Registry.new, quiet_reporter)
      allow(bridge).to receive(:require).with('yard').and_raise(LoadError)
      expect { bridge.merge([], root: Dir.pwd) }.to raise_error(Boondoc::Error, /needs the yard gem/)
    end
  end
end
