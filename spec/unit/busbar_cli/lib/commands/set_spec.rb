require 'spec_helper'

RSpec.describe Commands::Set do
  describe '#set' do
    class DummyClass < Thor
      include Commands::Set
    end

    subject do
      my_cli.set(
        'app_id',
        'environment_name',
        'MONGO_URL=mongodb://mongo', 'REDIS_URL=redis://redis'
      )
    end

    let(:my_cli) { DummyClass.new }

    let(:environment) { instance_double(Environment) }

    before do
      allow(Services::Settings).to receive(:set)

      allow(my_cli).to receive(:options).and_return(
        double(:options, deploy: true, profile: 'some.profile')
      )

      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)

      allow(AppsRepository).to receive(:find).and_return(instance_double(App))

      allow(EnvironmentsRepository).to receive(:find).and_return(instance_double(Environment))

      allow(Services::Kube).to receive(:configure_temporary_profile)
    end

    it 'sets the new variables' do
      expect(Services::Settings).to receive(:set)
        .with(environment, ['MONGO_URL=mongodb://mongo', 'REDIS_URL=redis://redis'], true)
        .once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end

    context 'when the user only sends settings as params' do
      subject do
        my_cli.set(
          'MONGO_URL=mongodb://mongo', 'REDIS_URL=redis://redis'
        )
      end

      before do
        allow(AppsRepository).to receive(:find).and_return(nil)

        allow(EnvironmentsRepository).to receive(:find).and_return(nil)

        allow(Services::AppConfig).to receive(:get_or_exit).with('app').and_return('config_app')

        allow(Services::AppConfig).to receive(:get_or_exit).with('environment').and_return('config_env')

        allow(my_cli).to receive(:puts)

        allow(Environment).to receive(:new)
          .with(app_id: 'config_app', name: 'config_env')
          .and_return(environment)
      end

      it 'warns the user that it is using the config values' do
        expect(my_cli).to receive(:puts)
          .with("Could not find app or environment provided. Using values from the config file\n")
          .once

        subject
      end

      it 'reaches the configs to use the default value for app' do
        expect(Services::AppConfig).to receive(:get_or_exit).with('app').once

        subject
      end

      it 'reaches the configs to use the default value for environment' do
        expect(Services::AppConfig).to receive(:get_or_exit).with('environment').once

        subject
      end

      it 'sets the new variables' do
        expect(Services::Settings).to receive(:set)
          .with(environment, ['MONGO_URL=mongodb://mongo', 'REDIS_URL=redis://redis'], true)
          .once

        subject
      end
    end
  end
end
