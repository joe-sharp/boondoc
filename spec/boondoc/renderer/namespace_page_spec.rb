# frozen_string_literal: true

RSpec.describe Boondoc::Renderer::NamespacePage do
  def inherited_lines(page)
    page.lines(chomp: true).grep(/\A- From /)
  end

  it "lists each inherited method once, under the ancestor it comes from" do
    pages, = render_source(<<~RUBY)
      class A
        def foo; end
        def bar; end
      end
      class B < A
        def foo; end
      end
      class C < B; end
    RUBY
    expect(inherited_lines(pages["C.md"])).to eq([
      "- From [`B`](B.md): [`#foo`](B.md#method-i-foo)",
      "- From [`A`](A.md): [`#bar`](A.md#method-i-bar)"
    ])
  end

  it "links a superclass that shares the name of the class", :aggregate_failures do
    pages, = render_source(<<~RUBY)
      class Error
        def report; end
      end
      module M
        class Error < Error; end
      end
    RUBY
    page = pages["M/Error.md"]
    expect(page).to include("- **Inherits:** [`Error`](../Error.md)")
    expect(inherited_lines(page)).to eq(["- From [`Error`](../Error.md): [`#report`](../Error.md#method-i-report)"])
  end
end
