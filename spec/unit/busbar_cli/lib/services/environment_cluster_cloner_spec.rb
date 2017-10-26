require 'spec_helper'

RSpec.describe Services::EnvironmentClusterCloner do
  describe '#call' do
    let(:app) do
      instance_double(
        App,
        id: 'app',
        buildpack_id: 'buildpack_id',
        repository: 'repository',
        default_branch: 'default_branch'
      )
    end

    let(:environment) do
      instance_double(
        Environment,
        app_id: 'app',
        name: 'staging',
        buildpack_id: 'buildpack_id',
        public: true,
        default_branch: 'default_branch',
        default_node_id: 'default_node_id',
        settings: {
          'FOO': 'foo-url'
        }
      )
    end

    before do
      allow(Services::AppCreator).to receive(:call)
      allow(Services::EnvironmentCreator).to receive(:call)
      allow(Services::Kube).to receive(:configure_temporary_profile)
      allow_any_instance_of(described_class).to receive(:puts)
    end

    subject do
      described_class.call(
        environment: environment,
        environment_clone_name: environment_clone_name,
        profile: 'profile',
        destination_cluster: 'destination-cluster'
      )
    end

    context 'when the environment exists on destination cluster' do
      before do
        allow(EnvironmentsRepository)
          .to receive(:find)
          .and_return(instance_double(Environment))
      end

      let(:environment_clone_name) { 'staging-clone' }

      it 'informs the user that the cloning have failed' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('the staging-clone already exist in the destination-cluster cluster please, try a different name')
          .once

        expect(-> { subject }).to exit_with_code(0)
      end
    end

    context 'cloning an app and environment' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:environment_exist_on_destination?)
          .and_return(nil)

        allow(AppsRepository)
          .to receive(:find)
          .with(app_id: environment.app_id)
          .and_return(app)

        allow(EnvironmentsRepository)
          .to receive(:find)
          .with(environment_name: environment.name, app_id: app.id)
          .and_return(environment)

        allow_any_instance_of(described_class).to receive(:app_exist_on_destination?).and_return(false)
      end

      let(:environment_attributes) do
        {
          buildpack_id: environment.buildpack_id,
          public: environment.public,
          default_branch: environment.default_branch,
          default_node_id: environment.default_node_id,
          settings: environment.settings
        }
      end

      context 'when environment_clone_name is nil' do
        let(:environment_clone_name) { nil }

        it 'calls the app creator with the given params' do
          expect(Services::AppCreator).to receive(:call).with(
            id: app.id,
            buildpack_id: app.buildpack_id,
            repository: app.repository,
            default_branch: app.default_branch,
            default_env: nil,
            environment: environment_attributes.merge(name: environment.name)
          ).once

          subject
        end
      end

      context 'when environment_clone_name is not nil' do
        let(:environment_clone_name) { 'environment_clone_name' }

        it 'calls the app creator with the given params' do
          expect(Services::AppCreator).to receive(:call).with(
            id: app.id,
            buildpack_id: app.buildpack_id,
            repository: app.repository,
            default_branch: app.default_branch,
            default_env: nil,
            environment: environment_attributes.merge(name: environment_clone_name)
          ).once

          subject
        end
      end
    end

    context 'cloning an environment only' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:environment_exist_on_destination?)
          .and_return(nil)

        allow_any_instance_of(described_class)
          .to receive(:app_exist_on_destination?)
          .and_return(true)

        allow(EnvironmentsRepository)
          .to receive(:find)
          .with(environment_name: environment.name, app_id: app.id)
          .and_return(environment)
      end

      context 'when environment_clone_name is nil' do
        let(:environment_clone_name) { nil }

        it 'calls the environment creator with the given attributes' do
          expect(Services::EnvironmentCreator).to receive(:call).with(
            app_id: environment.app_id,
            name: environment.name,
            buildpack_id: environment.buildpack_id,
            public: environment.public,
            default_branch: environment.default_branch,
            settings: environment.settings
          ).once

          subject
        end
      end

      context 'when environment_clone_name is not nil' do
        let(:environment_clone_name) { 'env-clone' }

        it 'calls the environment creator with the given attributes' do
          expect(Services::EnvironmentCreator).to receive(:call).with(
            app_id: environment.app_id,
            name: environment_clone_name,
            buildpack_id: environment.buildpack_id,
            public: environment.public,
            default_branch: environment.default_branch,
            settings: environment.settings
          ).once

          subject
        end
      end
    end
  end
end
