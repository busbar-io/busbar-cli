require 'spec_helper'

RSpec.describe Commands::Profile do
  describe '#profile' do
    class DummyClass < Thor
      include Commands::Profile
    end

    let(:my_cli) { DummyClass.new }

    context 'when profile_id is nil' do
      subject { my_cli.profile(nil) }

      it 'show current profile' do
        expect do
          subject
        end.to output("Busbar Profile: busbar_profile\n").to_stdout
      end
    end

    context 'when a profile id is given' do
      subject { my_cli.profile('test.profile') }

      before do
        allow(Services::Kube).to receive(:config_download)
        allow(Services::BusbarConfig).to receive(:set).with('busbar_profile', 'test.profile')
      end

      it 'validate the profile' do
        expect(Services::Kube).to receive(:validate_profile).with('test.profile').and_return(true)

        expect do
          subject
        end.to output("Busbar Profile: \n").to_stdout

        subject
      end

      it 'download the kube config file' do
        expect(Services::Kube).to receive(:config_download)

        expect do
          subject
        end.to output("test.profile\nBusbar Profile: \n").to_stdout

        subject
      end

      it 'set new profile and output it to stdout' do
        expect(Services::BusbarConfig).to receive(:set).with('busbar_profile', 'test.profile')

        expect do
          subject
        end.to output("test.profile\nBusbar Profile: \n").to_stdout

        subject
      end
    end
  end
end
