require 'spec_helper'

RSpec.describe Commands::Copy do
  describe '#copy' do
    class DummyClass < Thor
      include Commands::Copy
    end

    subject { my_cli.copy('source/file/path', 'destination/file/path') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(Kernel).to receive(:exec)
    end

    context 'with --container option' do
      it 'execs a cp command for the given container' do
        my_cli.options = double(:options, profile: 'current.profile', container: 'container')

        expect(Kernel).to receive(:exec)
          .with(
            "#{KUBECTL} --context=current.profile cp source/file/path destination/file/path -c container"
          )
        subject
      end
    end

    context 'without --container option' do
      it 'execs a cp command for the default container' do
        my_cli.options = double(:options, profile: 'current.profile', container: nil)

        expect(Kernel).to receive(:exec)
          .with(
            "#{KUBECTL} --context=current.profile cp source/file/path destination/file/path"
          )
        subject
      end
    end

    it 'uses the profile from the options' do
      my_cli.options = double(:options, profile: 'current.profile', container: 'container')

      expect(Services::Kube).to receive(:configure_temporary_profile).with('current.profile').once

      subject
    end
  end
end
