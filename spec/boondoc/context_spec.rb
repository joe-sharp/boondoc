# frozen_string_literal: true

RSpec.describe Boondoc::Context do
  let(:registry) do
    parse_source(<<~RUBY)
      class Foo
        def zed; end
        def initialize; end
        def new_name; end
        alias_method :old, :new_name
        alias_method :older, :new_name
        def self.build; end
      end
    RUBY
  end
  let(:context) do
    config = Boondoc::Config.new(root: Dir.pwd, readme: false)
    described_class.new(config: config, registry: registry, reporter: quiet_reporter)
  end
  let(:foo) { registry['Foo'] }

  describe '#meths' do
    it 'returns the namespace methods of a scope, initialize first, then by name', :aggregate_failures do
      expect(context.meths(foo, :instance).map(&:name)).to eq(%w[initialize new_name old older zed])
      expect(context.meths(foo, :class).map(&:name)).to eq(['build'])
    end

    it 'sorts them once and hands back the same list' do
      expect(context.meths(foo, :instance)).to equal(context.meths(foo, :instance))
    end
  end

  describe '#aliases' do
    it 'lists the aliases of each method name, in method order', :aggregate_failures do
      aliases = context.aliases(foo, :instance)
      expect(aliases['new_name'].map(&:name)).to eq(%w[old older])
      expect(aliases['zed']).to be_nil
    end

    it 'builds the index once' do
      expect(context.aliases(foo, :instance)).to equal(context.aliases(foo, :instance))
    end
  end
end
