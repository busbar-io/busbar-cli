require 'spec_helper'

RSpec.describe Commands::Create do
  describe '#create' do
    class DummyClass < Thor
      include Commands::Create
    end

    let(:my_cli) { DummyClass.new }

    subject { my_cli.create('app_id', 'environment_name') }

    before do
      allow(AppsRepository).to receive(:find)
        .with(app_id: 'app_id')
        .and_return(instance_double(App))

      allow(Services::AppCreator).to receive(:call)
      allow(Services::EnvironmentCreator).to receive(:call)
      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(my_cli).to receive(:puts)
    end

    before do
      my_cli.options = double(
        :options,
        repository: 'git@some_repo.git',
        buildpack_id: 'ruby',
        branch: 'develop',
        public: true,
        profile: 'some.profile'
      )
    end

    context 'with no environment_name param' do
      subject { my_cli.create('app_id') }

      it 'creates an app' do
        expect(Services::AppCreator).to receive(:call)
          .with(
            id: 'app_id',
            buildpack_id: 'ruby',
            default_branch: 'develop',
            repository: 'git@some_repo.git',
            default_env: nil,
            environment: nil
          ).once

        subject
      end

      it "prints 'Done!'" do
        expect(my_cli).to receive(:puts).with('Done!').once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'with environment_name param' do
      context 'when the app exists' do
        it 'creates an environment' do
          expect(Services::EnvironmentCreator).to receive(:call)
            .with(
              app_id: 'app_id',
              name: 'environment_name',
              buildpack_id: 'ruby',
              public: true,
              default_branch: 'develop',
              settings: nil
            ).once

          subject
        end

        it "prints 'Done!'" do
          expect(my_cli).to receive(:puts).with('Done!').once

          subject
        end

        it 'uses the profile from the options' do
          expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

          subject
        end
      end

      context 'when the app does not exist' do
        before do
          allow(AppsRepository).to receive(:find)
            .with(app_id: 'app_id')
            .and_return(nil)
        end

        it 'creates an app with the given environment as default environment' do
          expect(Services::AppCreator).to receive(:call)
            .with(
              id: 'app_id',
              buildpack_id: 'ruby',
              default_branch: 'develop',
              repository: 'git@some_repo.git',
              default_env: 'environment_name',
              environment: nil
            )
            .once

          subject
        end

        it "prints 'Done!'" do
          expect(my_cli).to receive(:puts).with('Done!').once

          subject
        end

        it 'uses the profile from the options' do
          expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

          subject
        end
      end
    end
  end
end
