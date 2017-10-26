require 'spec_helper'

RSpec.describe Commands::KubeSetup do
  describe '#kube_setup' do
    class DummyClass < Thor
      include Commands::KubeSetup
    end

    subject { my_cli.kube_setup }

    let(:my_cli) { DummyClass.new }

    before do
      allow(my_cli).to receive(:puts)
      allow(Services::Kube).to receive(:setup)
      allow(Services::BusbarConfig).to receive(:set)
      allow(Services::Kube).to receive(:contexts).and_return("first.profile\nsecond.profile")

      stub_const('BUSBAR_PROFILE', 'busbar.profile')
    end

    it 'prints a message about the setup' do
      expect(my_cli).to receive(:puts).with('Installing dependencies...').once

      subject
    end

    it 'sets up the CLI' do
      expect(Services::Kube).to receive(:setup).once

      subject
    end

    it 'prints a message about the profile setup' do
      expect(my_cli).to receive(:puts).with('Installing dependencies...').once

      subject
    end

    it 'prints a message about the setup end' do
      expect(my_cli).to receive(:puts).with('Done!').once

      subject
    end
  end
end
