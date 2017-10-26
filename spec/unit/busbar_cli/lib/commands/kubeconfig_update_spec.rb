require 'spec_helper'

RSpec.describe Commands::KubeConfigUpdate do
  describe '#kubeconfig_update' do
    class DummyClass < Thor
      include Commands::KubeConfigUpdate
    end

    subject { my_cli.kubeconfig_update }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:config_download)
      allow(my_cli).to receive(:puts)
    end

    it 'informs that the CLI will update the kubeconfig if needed' do
      expect(my_cli).to receive(:puts)
        .with("Checking if you are using the latest version of the kubectl config file\n" \
             'You\'ll see an update message if an update was necessary')
        .once
      subject
    end

    it 'updates the kubeconfig if needed' do
      expect(Services::Kube).to receive(:config_download).once
      subject
    end

    it 'informs that the operation was complete' do
      expect(my_cli).to receive(:puts).with('Done!').once
      subject
    end

    context 'with the --force option' do
      before do
        my_cli.options = double(:options, force?: true)
      end

      it 'downloads the kubeconfig file no matter what' do
        expect(Services::Kube).to receive(:config_download).once
        subject
      end
    end
  end
end
