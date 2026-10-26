# frozen_string_literal: true

RSpec.describe Boondoc::Renderer::MethodSection do
  let(:registry) do
    parse_source(<<~RUBY)
      class Foo
        attr_accessor :name
        attr_reader :size
        def self.build(name, size: 1); end
        def new_name; end
        alias_method :old, :new_name
        def plain; end
        private
        def hidden; end
      end
    RUBY
  end
  let(:section) do
    config = Boondoc::Config.new(root: Dir.pwd, readme: false, private: true)
    context = Boondoc::Context.new(config: config, registry: registry, reporter: quiet_reporter)
    described_class.new(context, 'Foo.md')
  end

  def blocks(path) = section.render(registry[path]).join("\n")

  describe '#signature' do
    it 'writes class methods with self and keeps the parameters', :aggregate_failures do
      expect(section.signature(registry['Foo.build'])).to eq('def self.build(name, size: 1)')
      expect(section.signature(registry['Foo#plain'])).to eq('def plain')
    end
  end

  describe '#render_attribute' do
    it 'merges a reader and a writer into one attr_accessor entry', :aggregate_failures do
      text = section.render_attribute([registry['Foo#name'], registry['Foo#name=']]).join("\n")
      expect(text).to include('<a id="method-i-name"></a><a id="method-i-name-3D"></a>`#name`')
      expect(text).to include('attr_accessor :name')
    end

    it 'names a lone reader attr_reader' do
      expect(section.render_attribute([registry['Foo#size']]).join("\n")).to include('attr_reader :size')
    end
  end

  describe '#render' do
    it 'links an alias to the method it is an alias for' do
      expect(blocks('Foo#old')).to include('- **Alias for:** [`#new_name`](#method-i-new_name)')
    end

    it 'lists the aliases on the original' do
      expect(blocks('Foo#new_name')).to include('- **Also known as:** [`#old`](#method-i-old)')
    end

    it 'states the visibility of a method that is not public' do
      expect(blocks('Foo#hidden')).to include('- **Visibility:** private')
    end

    it 'adds no facts for a plain public method' do
      expect(blocks('Foo#plain')).not_to include('**')
    end
  end
end
