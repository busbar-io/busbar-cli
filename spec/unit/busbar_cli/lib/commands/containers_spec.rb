require 'spec_helper'

RSpec.describe Commands::Containers do
  describe '#containers' do
    class DummyClass < Thor
      include Commands::Containers
    end

    subject { my_cli.containers('app_id', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Kernel).to receive(:exec)

      allow(my_cli).to receive(:options).and_return(
        double(:options, profile: 'some.profile')
      )

      allow(Services::Kube).to receive(:configure_temporary_profile)
      allow(Services::Kube).to receive(:setup)
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')
    end

    it 'ensures kubectl dependencies are downloaded' do
      expect(Kernel).to receive(:exec)
        .with(
          "#{KUBECTL} --context=current.profile " \
          'get pods -l busbar.io/app=app_id -n environment_name'
        )

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
