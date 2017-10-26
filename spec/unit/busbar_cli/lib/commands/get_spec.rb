require 'spec_helper'

RSpec.describe Commands::Get do
  describe '#get_config' do
    class DummyClass < Thor
      include Commands::Get
    end

    subject { my_cli.get_config('app_id', 'environment_name', 'setting_key') }

    let(:my_cli) { DummyClass.new }

    let(:environment) do
      instance_double(
        Environment,
        app_id: 'app_id',
        name: 'environment_name'
      )
    end

    before do
      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)

      allow(Services::Settings).to receive(:get)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'retrieves the value of the given setting in the given environment' do
      expect(Services::Settings).to receive(:get).with(environment, 'setting_key').once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
