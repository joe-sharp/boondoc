# frozen_string_literal: true

RSpec.describe Boondoc::Writer do
  around { |example| Dir.mktmpdir('boondoc') { |dir| @dir = dir and example.run } }

  let(:dir) { @dir } # rubocop:disable RSpec/InstanceVariable
  let(:reporter) { quiet_reporter }

  def write(force: false, **pages)
    described_class.new(dir, reporter, force: force).write(pages)
  end

  it 'writes nested pages' do
    write('a/b/C.md' => "hi\n")
    expect(File.read(File.join(dir, 'a/b/C.md'))).to eq("hi\n")
  end

  describe 'assets' do
    let(:source) { File.join(dir, 'source.bin') }

    before { File.binwrite(source, "\x00\xFFbinary\n".b) }

    def write_assets(assets)
      described_class.new(dir, reporter).write({ 'index.md' => "hi\n" }, assets: assets)
    end

    it 'copies a file byte for byte, into the manifest too', :aggregate_failures do
      write_assets('media/copy.bin' => source)
      expect(File.binread(File.join(dir, 'media/copy.bin'))).to eq(File.binread(source))
      expect(File.readlines(File.join(dir, Boondoc::Writer::MANIFEST), chomp: true)).to include('media/copy.bin')
    end

    it 'leaves an unchanged copy alone, so its modification time does not move', :aggregate_failures do
      write_assets('copy.bin' => source)
      copy = File.join(dir, 'copy.bin')
      File.utime(Time.at(1_000_000), Time.at(1_000_000), copy)
      write_assets('copy.bin' => source)
      expect(File.mtime(copy).to_i).to eq(1_000_000)
    end

    it 'removes an asset that is no longer copied', :aggregate_failures do
      write_assets('copy.bin' => source)
      stale = described_class.new(dir, reporter).write({ 'index.md' => "hi\n" })
      expect(stale).to eq(['copy.bin'])
      expect(File).not_to exist(File.join(dir, 'copy.bin'))
    end

    it 'refuses to overwrite a file that Boondoc did not copy' do
      File.write(File.join(dir, 'copy.bin'), 'mine')
      expect { write_assets('copy.bin' => source) }.to raise_error(Boondoc::Error, /did not generate/)
    end

    it 'refuses a page and an asset at the same path' do
      expect { described_class.new(dir, reporter).write({ 'x.md' => 'a' }, assets: { 'x.md' => source }) }
        .to raise_error(Boondoc::Error, /would both be written to x.md/)
    end
  end

  it 'removes stale pages and their empty directories, but nothing else', :aggregate_failures do
    write('a/b/C.md' => 'x', 'keep.md' => 'x')
    File.write(File.join(dir, 'mine.md'), 'hand written')
    expect(write('keep.md' => 'y')).to eq(['a/b/C.md'])
    expect(Dir.children(dir).sort).to eq(%w[.boondoc-manifest keep.md mine.md])
  end

  it 'refuses to overwrite a file it did not generate', :aggregate_failures do
    File.write(File.join(dir, 'index.md'), 'hand written')
    expect { write('index.md' => 'x') }.to raise_error(Boondoc::Error, /refusing to overwrite 1 file/)
    expect(File.read(File.join(dir, 'index.md'))).to eq('hand written')
  end

  it 'overwrites foreign files with force' do
    File.write(File.join(dir, 'index.md'), 'hand written')
    write('index.md' => 'x', force: true)
    expect(File.read(File.join(dir, 'index.md'))).to eq('x')
  end

  it 'ignores manifest entries that point outside the output directory' do # rubocop:disable RSpec/ExampleLength
    outside = File.join(File.dirname(dir), "boondoc-outside-#{Process.pid}.md")
    File.write(outside, 'safe')
    File.write(File.join(dir, '.boondoc-manifest'), "../#{File.basename(outside)}\n#{outside}\n")
    write('a.md' => 'x')
    expect(File).to exist(outside)
  ensure
    FileUtils.rm_f(outside)
  end

  describe 'pages that have not changed' do
    let(:old) { Time.at(1_000_000_000) }

    def age(*names)
      names.each { |name| File.utime(old, old, File.join(dir, name)) }
    end

    def mtime(name) = File.mtime(File.join(dir, name))

    it 'are left alone, so file watchers and build tools see no change', :aggregate_failures do
      write('a.md' => 'same')
      age('a.md', '.boondoc-manifest')
      write('a.md' => 'same')
      expect(mtime('a.md')).to eq(old)
      expect(mtime('.boondoc-manifest')).to eq(old)
    end

    it 'are rewritten when the content differs', :aggregate_failures do
      write('a.md' => 'before')
      age('a.md')
      write('a.md' => 'after')
      expect(File.read(File.join(dir, 'a.md'))).to eq('after')
      expect(mtime('a.md')).to be > old
    end

    it 'are rewritten when only the length matches', :aggregate_failures do
      write('a.md' => 'abcd')
      age('a.md')
      write('a.md' => 'abce')
      expect(File.read(File.join(dir, 'a.md'))).to eq('abce')
      expect(mtime('a.md')).to be > old
    end
  end

  describe 'staying inside the output directory' do
    around do |example|
      Dir.mktmpdir('boondoc-outside') { |outside| @outside = outside and example.run }
    end

    let(:outside) { @outside } # rubocop:disable RSpec/InstanceVariable

    it 'refuses to write a page through a symlink', :aggregate_failures do
      File.write(File.join(outside, 'target.sh'), 'original')
      File.symlink(File.join(outside, 'target.sh'), File.join(dir, 'Foo.md'))
      File.write(File.join(dir, '.boondoc-manifest'), "Foo.md\n")
      expect { write('Foo.md' => 'x') }.to raise_error(Boondoc::Error, /symlink/)
      expect(File.read(File.join(outside, 'target.sh'))).to eq('original')
    end

    it 'refuses a page that is a symlink to a file with the same content' do
      File.write(File.join(outside, 'target.md'), 'same')
      File.symlink(File.join(outside, 'target.md'), File.join(dir, 'Foo.md'))
      File.write(File.join(dir, '.boondoc-manifest'), "Foo.md\n")
      expect { write('Foo.md' => 'same') }.to raise_error(Boondoc::Error, /symlink/)
    end

    it 'refuses to write a page into a symlinked directory', :aggregate_failures do
      File.symlink(outside, File.join(dir, 'files'))
      expect { write('files/x.md' => 'x') }.to raise_error(Boondoc::Error, /symlink/)
      expect(Dir.children(outside)).to be_empty
    end

    it 'refuses a page path that leaves the output directory', :aggregate_failures do
      escape = "../#{File.basename(outside)}/x.md"
      expect { write(escape => 'x') }.to raise_error(Boondoc::Error, /outside/)
      expect(Dir.children(outside)).to be_empty
    end

    it 'does not remove stale pages through a symlinked directory' do
      File.write(File.join(outside, 'old.md'), 'keep me')
      File.symlink(outside, File.join(dir, 'sub'))
      File.write(File.join(dir, '.boondoc-manifest'), "sub/old.md\n")
      write('a.md' => 'x')
      expect(File.read(File.join(outside, 'old.md'))).to eq('keep me')
    end

    context 'with a symlink followed by `..`' do
      before do
        Dir.mkdir(File.join(outside, 'inner'))
        File.symlink(File.join(outside, 'inner'), File.join(dir, 'link'))
      end

      it 'does not remove stale pages named that way', :aggregate_failures do
        File.write(File.join(outside, 'old.md'), 'keep me')
        File.write(File.join(dir, '.boondoc-manifest'), "link/../old.md\n")
        write('a.md' => 'x')
        expect(File.read(File.join(outside, 'old.md'))).to eq('keep me')
      end

      it 'refuses to write a page named that way', :aggregate_failures do
        expect { write('link/../new.md' => 'x') }.to raise_error(Boondoc::Error, /`\.\.`/)
        expect(File).not_to exist(File.join(outside, 'new.md'))
      end

      it 'refuses to copy an asset named that way', :aggregate_failures do
        source = File.join(outside, 'source.bin')
        File.write(source, 'x')
        expect { described_class.new(dir, reporter).write({}, assets: { 'link/../new.bin' => source }) }
          .to raise_error(Boondoc::Error, /`\.\.`/)
        expect(File).not_to exist(File.join(outside, 'new.bin'))
      end
    end

    it 'keeps manifest entries whose names merely contain two dots' do
      write('a..b.md' => 'x')
      expect(write('c.md' => 'y')).to eq(['a..b.md'])
    end
  end

  # On a case-insensitive filesystem the old and new names are the same file.
  [false, true].each do |force|
    it "keeps a page whose name changed only by case (force: #{force})", :aggregate_failures do
      write('Html.md' => 'old')
      write('HTML.md' => 'new', force: force)
      expect(Dir.children(dir).sort).to eq(%w[.boondoc-manifest HTML.md])
      expect(File.read(File.join(dir, 'HTML.md'))).to eq('new')
    end
  end

  describe 'paths that differ only by case' do
    it 'warns, naming both paths in a fixed order and what to do', :aggregate_failures do
      write('Foo.md' => 'x', 'FOO.md' => 'y')
      expect(reporter.warnings).to eq(
        ['FOO.md and Foo.md differ only by case and will collide on case-insensitive filesystems; ' \
         'rename one of them']
      )
    end

    it 'warns when a page and an asset differ only by case' do
      source = File.join(dir, 'source.bin')
      File.write(source, 'x')
      described_class.new(dir, reporter).write({ 'files/Guide.md' => 'x' }, assets: { 'files/GUIDE.md' => source })
      expect(reporter.warnings.size).to eq(1)
    end

    it 'warns once per group of colliding paths' do
      write('Foo.md' => 'x', 'FOO.md' => 'y', 'Bar.md' => 'z', 'BAR.md' => 'w')
      expect(reporter.warnings.size).to eq(2)
    end

    it 'does not warn for the kind-suffixed pages of classes and modules' do
      write('Guard/CLI.class.md' => 'x', 'Guard/Cli.module.md' => 'y', 'Guard/Cli.module/Valid.md' => 'z')
      expect(reporter.warnings).to be_empty
    end
  end
end
