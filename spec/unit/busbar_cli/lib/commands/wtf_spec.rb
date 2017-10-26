require 'spec_helper'

RSpec.describe Commands::Wtf do
  describe '#wtf' do
    class DummyClass < Thor
      include Commands::Wtf
    end

    subject { my_cli.wtf('container', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:setup)

      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(Kernel).to receive(:exec)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'execs a logs command for the given container' do
      expect(Kernel).to receive(:exec)
        .with(
          "#{KUBECTL} --context=current.profile logs -p container -n environment_name"
        )
      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
