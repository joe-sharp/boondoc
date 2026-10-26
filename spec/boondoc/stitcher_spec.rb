# frozen_string_literal: true

RSpec.describe Boondoc::Stitcher do
  include_context 'with a sandbox'

  def write(path, content = "# #{path}\n")
    File.join(project, path).tap do |full|
      FileUtils.mkdir_p(File.dirname(full))
      File.write(full, content)
    end
  end

  def stitcher(**options)
    described_class.new(Boondoc::Config.new(root: project, **options))
  end

  def relocated(content, files: ['guides/*.md'])
    write('guides/intro.md', content)
    stitched = stitcher(readme: false, files: files)
    stitched.relocated_content(stitched.find('guides/intro.md'))
  end

  describe Boondoc::ExtraFile do
    def file(content, source: 'guides/intro.md')
      described_class.new(source: source, output: "files/#{source}", content: content, readme: false)
    end

    it 'uses the first top-level heading as the title', :aggregate_failures do
      expect(file("text\n# The Guide #\n## Sub\n").title).to eq('The Guide')
      expect(file("# Plain\n").title).to eq('Plain')
    end

    it 'falls back to the file name without extension' do
      expect(file("no heading\n", source: 'guides/setup-notes.md').title).to eq('setup-notes')
    end
  end

  describe '#files' do
    it 'puts the README first, written to the index page', :aggregate_failures do
      write('README.md')
      write('CHANGELOG.md')
      stitched = stitcher(files: ['CHANGELOG.md'])
      expect(stitched.files.map(&:source)).to eq(%w[README.md CHANGELOG.md])
      expect(stitched.readme).to have_attributes(output: 'README.md', readme: true)
    end

    it 'writes other files under files/ with a .md extension', :aggregate_failures do
      write('guides/intro.md')
      write('LICENSE.txt', "MIT\n")
      stitched = stitcher(readme: false, files: ['guides/*.md', 'LICENSE.txt'])
      expect(stitched.files.map(&:output)).to eq(%w[files/LICENSE.txt.md files/guides/intro.md])
    end

    it 'shows a non-markdown file as a code block' do
      write('LICENSE.txt', "MIT\n")
      stitched = stitcher(readme: false, files: ['LICENSE.txt'])
      expect(stitched.files.first.content).to eq("# LICENSE.txt\n\n```\nMIT\n```\n")
    end
  end

  describe '#find' do
    let(:stitched) do
      write('guides/intro.md')
      stitcher(readme: false, files: ['guides/*.md'])
    end

    it 'finds a file by path, file name and file name without extension', :aggregate_failures do
      found = stitched.find('guides/intro.md')
      expect(found).to have_attributes(source: 'guides/intro.md')
      expect(stitched.find('intro.md')).to equal(found)
      expect(stitched.find('intro')).to equal(found)
    end

    it 'returns nil for an unknown name' do
      expect(stitcher(readme: false).find('nope')).to be_nil
    end
  end

  describe '#relocated_content' do
    it 'rewrites relative links and images so they still point at the same file', :aggregate_failures do
      write('assets/logo.png', 'png')
      text = relocated("[a](../assets/logo.png) and ![b](logo.png)\n")
      expect(text).to include('[a](../../../assets/logo.png)')
      expect(text).to include('![b](../../../guides/logo.png)')
    end

    it 'rewrites reference-style definitions and HTML attributes', :aggregate_failures do
      text = relocated("[ref]: ../assets/a.png\n\n<img src=\"../assets/b.png\">\n")
      expect(text).to include('[ref]: ../../../assets/a.png')
      expect(text).to include('<img src="../../../assets/b.png">')
    end

    it 'keeps a fragment on a rewritten link' do
      write('assets/page.md')
      expect(relocated("[a](../assets/page.md#top)\n")).to include('[a](../../../assets/page.md#top)')
    end

    it 'follows a link to another stitched file to its new home, and not to the original' do
      write('other/page.md')
      text = relocated("[o](../other/page.md)\n", files: ['guides/*.md', 'other/*.md'])
      expect(text).to include('[o](../other/page.md)')
    end

    it 'leaves external, anchor-only and absolute links alone', :aggregate_failures do
      content = "[a](https://example.com/x) [b](#top) [c](/abs/path) [d](mailto:a@b.c) [e]({Foo})\n"
      expect(relocated(content)).to eq(content)
    end

    it 'leaves links in code blocks and code spans alone', :aggregate_failures do
      content = "`[a](../x.png)`\n\n```\n[b](../y.png)\n```\n"
      expect(relocated(content)).to eq(content)
    end
  end
end
