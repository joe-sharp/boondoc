# frozen_string_literal: true

RSpec.describe Boondoc::Preview do
  let(:silent) { described_class::SILENT }
  let(:answers) { [] }

  def preview(dir, **, &confirm)
    described_class.new(dir, **, &confirm).tap do |instance|
      allow(instance).to receive(:system) do |*command, **|
        answers << command
        results.fetch(command.first(3), true)
      end
    end
  end

  def commands
    answers.map { |command| command.join(" ") }
  end

  context "when gh and the extension are installed" do
    let(:results) { {} }

    it "starts the previewer inside the docs directory on 127.0.0.1" do
      Dir.mktmpdir do |dir|
        instance = preview(dir)
        instance.start
        expect(instance).to have_received(:system).with("gh", "markdown-preview", "--host", "127.0.0.1", chdir: dir)
      end
    end

    it "passes the host and port along" do
      Dir.mktmpdir do |dir|
        preview(dir, host: "localhost", port: 4000).start
        expect(commands.last).to eq("gh markdown-preview --host localhost --port 4000")
      end
    end

    ["127.0.0.1", "::1", "localhost"].each do |host|
      it "does not warn about the loopback host #{host}" do
        Dir.mktmpdir { |dir| expect { preview(dir, host: host).start }.not_to output.to_stderr }
      end
    end

    ["0.0.0.0", "192.168.1.20"].each do |host|
      it "warns that #{host} exposes any file the user can read, and still serves", :aggregate_failures do
        Dir.mktmpdir do |dir|
          expect { preview(dir, host: host).start }.to output(/exposes .*any file/m).to_stderr
          expect(commands.last).to eq("gh markdown-preview --host #{host}")
        end
      end
    end

    it "fails when the docs have not been generated", :aggregate_failures do
      expect { preview("/no/such/docs").start }.to raise_error(Boondoc::Error, /run `boondoc` first/)
      expect(commands).to be_empty
    end
  end

  context "when gh is missing" do
    let(:results) { { %w[gh --version] => nil } }

    it "says the GitHub CLI is needed" do
      Dir.mktmpdir do |dir|
        expect { preview(dir).start }.to raise_error(Boondoc::Error, /needs the GitHub CLI/)
      end
    end
  end

  context "when the extension is missing" do
    let(:results) { { %w[gh markdown-preview --version] => false } }

    it "installs it after confirmation and then serves" do
      Dir.mktmpdir do |dir|
        preview(dir) { true }.start
        expect(commands.last(2)).to eq(
          [
            "gh extension install yusukebe/gh-markdown-preview",
            "gh markdown-preview --host 127.0.0.1"
          ]
        )
      end
    end

    it "does not install when the user declines", :aggregate_failures do
      Dir.mktmpdir do |dir|
        expect { preview(dir) { false }.start }.to raise_error(Boondoc::Error, /gh extension install/)
        expect(commands).not_to include(a_string_matching(/extension install/))
      end
    end

    it "reports a failed install" do
      results[%w[gh extension install]] = false
      Dir.mktmpdir do |dir|
        expect { preview(dir) { true }.start }.to raise_error(Boondoc::Error, /could not install/)
      end
    end
  end
end
