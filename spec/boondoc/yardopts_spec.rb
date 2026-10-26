# frozen_string_literal: true

RSpec.describe Boondoc::Yardopts do
  include_context 'with a sandbox'

  def settings(text)
    described_class.parse(text).settings
  end

  it 'reads sources, extra files after a dash, the title, and visibility', :aggregate_failures do
    expect(settings(%(--title "My Gem" --private --protected lib app/**/*.rb - CHANGELOG.md guides/*.md))).to eq(
      title: 'My Gem', private: true, protected: true, sources: ['lib', 'app/**/*.rb'],
      files: ['CHANGELOG.md', 'guides/*.md']
    )
  end

  it 'reads options split over lines, with an equals sign, or glued to a short flag', :aggregate_failures do
    parsed = described_class.parse("--title=Gem\n-rREADME.md\n--files a.md,b.md\nlib\n")
    expect(parsed.settings).to eq(title: 'Gem', readme: 'README.md', files: ['a.md', 'b.md'], sources: ['lib'])
  end

  it 'reads --asset as an asset to copy, with an optional destination' do
    expect(settings('--asset images --asset logo.png:media')).to eq(assets: ['images', 'logo.png:media'])
  end

  it 'reads --readme and --main as the readme' do
    expect([settings('--main A.md'), settings('-r B.md')]).to eq([{ readme: 'A.md' }, { readme: 'B.md' }])
  end

  it 'does not take a source for the argument of an option it ignores', :aggregate_failures do
    parsed = described_class.parse('--markup markdown --plugin yard-foo --no-api public -q lib')
    expect(parsed.settings).to eq(sources: ['lib'])
    expect(parsed.ignored).to eq(%w[--markup --plugin --no-api -q])
  end

  it 'lets an optional argument take the next word unless it is another option', :aggregate_failures do
    expect(described_class.parse('--use-cache --yardopts lib').ignored).to eq(%w[--use-cache --yardopts])
    expect(described_class.parse('--use-cache --yardopts lib').settings).to eq({})
    expect(settings('--embed-mixins lib')).to eq(sources: ['lib'])
  end

  it 'keeps --output-dir out of the settings', :aggregate_failures do
    parsed = described_class.parse('-o doc lib')
    expect(parsed.output_dir).to eq('doc')
    expect(parsed.settings).to eq(sources: ['lib'])
  end

  it 'drops C sources and says so', :aggregate_failures do
    parsed = described_class.parse('lib/**/*.rb ext/**/*.c ext/foo.h')
    expect(parsed.settings).to eq(sources: ['lib/**/*.rb'])
    expect(parsed.ignored).to eq(['ext/**/*.c', 'ext/foo.h'])
  end

  it 'collects --exclude patterns as regular expressions' do
    parsed = described_class.parse('--exclude legacy --exclude=\.generated\z lib')
    expect(parsed.exclude.map { |pattern| pattern.match?('lib/legacy/a.rb') }).to eq([true, false])
  end

  it 'raises on unbalanced quotes' do
    expect { described_class.parse('--title "Oops') }.to raise_error(Boondoc::Error, /could not read \.yardopts/)
  end

  it 'raises on an --exclude pattern that is not a regular expression' do
    expect { described_class.parse('--exclude (') }.to raise_error(Boondoc::Error, /not a regular expression/)
  end

  describe '.read' do
    it 'returns nil without a .yardopts' do
      expect(described_class.read(project)).to be_nil
    end

    it 'parses the file in the project' do
      File.write(File.join(project, '.yardopts'), "--title Foo\n")
      expect(described_class.read(project).settings).to eq(title: 'Foo')
    end
  end

  describe '#notes' do
    it 'reports an --output-dir that differs from the output directory, and what was ignored', :aggregate_failures do
      notes = described_class.parse('-o doc --markup markdown').notes(output: 'docs', root: project)
      expect(notes.first).to include('ignoring --output-dir doc from .yardopts; writing to docs')
      expect(notes.last).to eq('ignoring from .yardopts: --markup')
    end

    it 'says nothing when the directories match and nothing was skipped' do
      expect(described_class.parse('-o docs lib').notes(output: './docs', root: project)).to be_empty
    end
  end
end
