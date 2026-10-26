# frozen_string_literal: true

RSpec.describe Boondoc::Frontend::Comments do
  def comments(source)
    described_class.new(Prism.parse(source))
  end

  it 'finds the block that ends on the line above a definition' do
    source = "# One.\n# Two.\ndef a; end\n"
    expect(comments(source).docstring_for(3)).to eq("One.\nTwo.")
  end

  it 'finds nothing when a blank line separates the comment from the definition' do
    expect(comments("# Detached.\n\ndef a; end\n").docstring_for(3)).to be_nil
  end

  it 'splits a block where the column changes' do
    source = "# Outer.\n  # Inner.\ndef a; end\n"
    expect(comments(source).docstring_for(3)).to eq('Inner.')
  end

  it 'drops magic comments and tool pragmas', :aggregate_failures do
    source = "# frozen_string_literal: true\n# rubocop:disable Style/Foo\n# Real.\ndef a; end\n"
    expect(comments(source).docstring_for(4)).to eq('Real.')
    expect(comments("# rubocop:disable Style/Foo\ndef a; end\n").docstring_for(2)).to be_nil
  end

  it 'removes the common indentation' do
    expect(comments("#   indented\n#     more\ndef a; end\n").docstring_for(3)).to eq("indented\n  more")
  end

  it 'reports a trailing :nodoc: on its own line only', :aggregate_failures do
    parsed = comments("def a; end # :nodoc:\ndef b; end\n")
    expect(parsed.nodoc?(1)).to be(true)
    expect(parsed.nodoc?(2)).to be(false)
  end

  it 'lists the last lines of blocks that use YARD directives' do
    source = "# @!macro [new] thing\n#   A thing.\nfoo :a\n\n# Plain.\ndef b; end\n"
    expect(comments(source).directive_lines).to eq([2])
  end
end
