require 'spec_helper'

RSpec.describe Commands::Publish do
  describe '#publish' do
    class DummyClass < Thor
      include Commands::Publish
    end

    subject { my_cli.publish('app_id', 'environment_name') }

    let(:my_cli) { DummyClass.new }
    let(:environment) { instance_double(Environment) }

    before do
      allow(Services::Publisher).to receive(:call)

      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'publishes the environment' do
      expect(Services::Publisher).to receive(:call).with(environment).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
