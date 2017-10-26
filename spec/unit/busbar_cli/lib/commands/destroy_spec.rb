require 'spec_helper'

RSpec.describe Commands::Destroy do
  describe '#destroy' do
    class DummyClass < Thor
      include Commands::Destroy
    end

    let(:my_cli) { DummyClass.new }

    before do
      my_cli.options = double(:options, profile: 'some.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)
    end

    context 'with no environment_name param' do
      subject { my_cli.destroy('app_id') }

      let(:app) { instance_double(App, id: 'app_id') }

      before do
        allow(Services::AppDestroyer).to receive(:call).with(app)

        allow(App).to receive(:new).with(id: 'app_id').and_return(app)
      end

      it 'destroys the given app' do
        expect(Services::AppDestroyer).to receive(:call)
          .with(app).once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'with environment_name' do
      subject { my_cli.destroy('app_id', 'environment_name') }

      let(:environment) do
        instance_double(Environment, app_id: 'app_id', name: 'environment_name')
      end

      before do
        allow(Services::EnvironmentDestroyer).to receive(:call).with(environment)

        allow(Environment).to receive(:new)
          .with(app_id: 'app_id', name: 'environment_name')
          .and_return(environment)
      end

      it 'destroys the given environment' do
        expect(Services::EnvironmentDestroyer).to receive(:call)
          .with(environment).once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end
  end
end
