require 'spec_helper'

RSpec.describe Commands::Profiles do
  describe '#profiles' do
    class DummyClass < Thor
      include Commands::Profiles
    end

    subject { my_cli.profiles }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:config_download)
      allow(Services::Kube).to receive(:contexts)
        .and_return("profile_1\nprofile2\nprofile3")

      allow(my_cli).to receive(:puts)
    end

    it 'downloads the kubeconfig file' do
      expect(Services::Kube).to receive(:config_download).once

      subject
    end

    it 'prints the available profiles' do
      expect(my_cli).to receive(:puts)
        .with("Available profiles:\nprofile_1\nprofile2\nprofile3")
        .once

      subject
    end
  end
end
