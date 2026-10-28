# frozen_string_literal: true

RSpec.describe Boondoc::Markdown do
  def upcase_prose(text)
    described_class.map_prose(text, &:upcase)
  end

  it "rewrites prose and leaves fenced code alone" do
    expect(upcase_prose("hello\n\n```ruby\ncode {x}\n```\nbye\n")).to eq("HELLO\n\n```ruby\ncode {x}\n```\nBYE\n")
  end

  it "leaves tilde fences and longer fences alone" do
    text = "~~~\ncode\n~~~\n````\n```\nstill code\n````\nprose"
    expect(upcase_prose(text)).to eq("~~~\ncode\n~~~\n````\n```\nstill code\n````\nPROSE")
  end

  it "leaves indented code blocks alone" do
    expect(upcase_prose("para\n\n    code\n    more\n\nafter")).to eq("PARA\n\n    code\n    more\n\nAFTER")
  end

  it "treats indented continuation of a list as prose" do
    expect(upcase_prose("- item\n\n    nested\n")).to eq("- ITEM\n\n    NESTED\n")
  end

  it "leaves inline code spans alone" do
    expect(upcase_prose("use `code` and ``more `x` code`` here")).to eq("USE `code` AND ``more `x` code`` HERE")
  end

  it "escapes pipes and newlines for table cells" do
    expect(described_class.table_cell("a | b\n c")).to eq('a \\| b c')
  end
end
