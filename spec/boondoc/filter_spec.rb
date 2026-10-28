# frozen_string_literal: true

RSpec.describe Boondoc::Filter do
  let(:registry) do
    parse_source(<<~RUBY)
      class Open
        def shown; end
        protected
        def guarded; end
        private
        def hidden; end
      end

      # @api private
      class Internal
        class Inner
          def deep; end
        end
      end
    RUBY
  end

  def visible?(path, **options)
    described_class.new(Boondoc::Config.new(**options)).visible?(registry[path])
  end

  it "shows public objects and the root", :aggregate_failures do
    expect(visible?("Open#shown")).to be(true)
    expect(visible?("")).to be(true)
  end

  it "hides private and protected methods by default", :aggregate_failures do
    expect(visible?("Open#hidden")).to be(false)
    expect(visible?("Open#guarded")).to be(false)
  end

  it "shows protected methods with protected but not private ones", :aggregate_failures do
    expect(visible?("Open#guarded", protected: true)).to be(true)
    expect(visible?("Open#hidden", protected: true)).to be(false)
  end

  it "shows everything with private", :aggregate_failures do
    expect(visible?("Open#hidden", private: true)).to be(true)
    expect(visible?("Open#guarded", private: true)).to be(true)
  end

  it "hides @api private objects and everything inside them", :aggregate_failures do
    expect(visible?("Internal")).to be(false)
    expect(visible?("Internal::Inner")).to be(false)
    expect(visible?("Internal::Inner#deep")).to be(false)
  end

  it "shows @api private objects with private", :aggregate_failures do
    expect(visible?("Internal", private: true)).to be(true)
    expect(visible?("Internal::Inner#deep", private: true)).to be(true)
  end
end
