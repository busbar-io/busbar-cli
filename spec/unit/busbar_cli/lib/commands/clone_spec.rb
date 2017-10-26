require 'spec_helper'

RSpec.describe Commands::Clone do
  describe '#apps' do
    class DummyClass < Thor
      include Commands::Clone
    end

    let(:my_cli) { DummyClass.new }
    let(:environment) do
      instance_double(Environment)
    end

    before do
      allow(Services::EnvironmentCloner).to receive(:call)
      allow(Services::EnvironmentClusterCloner).to receive(:call)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(my_cli).to receive(:puts)

      allow(Environment).to receive(:new)
        .with(app_id: 'some_app', name: 'staging')
        .and_return(environment)

      my_cli.options = double(:options, profile: 'some.profile', cluster: cluster)
    end

    context 'cloning an environment in same cluster' do
      let(:cluster) { nil }

      context 'when ENVIRONMENT_CLONE_NAME is not present' do
        subject { my_cli.clone('some_app', 'staging', nil) }

        before do
          allow(my_cli).to receive(:exit)
        end

        it 'does not clone the environment' do
          expect(Services::EnvironmentCloner).not_to receive(:call)

          subject
        end

        it 'prints a message warning about the missing environment clone param' do
          expect(my_cli).to receive(:puts)
            .with('Param missing: [ENVIRONMENT_CLONE_NAME]')

          subject
        end
      end

      context 'when ENVIRONMENT_CLONE_NAME is present' do
        subject { my_cli.clone('some_app', 'staging', 'staging-clone') }

        it 'clones the environment' do
          expect(Services::EnvironmentCloner).to receive(:call)
            .with(environment, 'staging-clone')
            .once

          subject
        end

        it 'uses the profile from the options' do
          expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

          subject
        end
      end
    end

    context 'cloning an environment across cluster' do
      subject { my_cli.clone('some_app', 'staging', 'staging-clone') }

      let(:cluster) { 'some-cluster' }

      context 'when not pass a profile' do
        it 'pass the current profile to the command' do
          my_cli.options = double(:options, profile: nil, cluster: cluster)

          allow(Services::Kube).to receive(:current_profile).and_return('current.profile')

          expect(Services::EnvironmentClusterCloner).to receive(:call)
            .with(
              environment: environment,
              environment_clone_name: 'staging-clone',
              destination_cluster: cluster,
              profile: 'current.profile'
            ).once

          subject
        end
      end

      context 'when ENVIRONMENT_CLONE_NAME is present' do
        subject { my_cli.clone('some_app', 'staging', 'staging-clone') }

        it 'clones the environment across cluster' do
          expect(Services::EnvironmentClusterCloner).to receive(:call)
            .with(
              environment: environment,
              environment_clone_name: 'staging-clone',
              destination_cluster: cluster,
              profile: 'some.profile'
            ).once

          subject
        end

        it 'uses the profile from the options' do
          expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

          subject
        end
      end

      context 'when ENVIRONMENT_CLONE_NAME is not present' do
        subject { my_cli.clone('some_app', 'staging', nil) }

        it 'clones the environment across cluster' do
          expect(Services::EnvironmentClusterCloner).to receive(:call)
            .with(
              environment: environment,
              environment_clone_name: nil,
              destination_cluster: cluster,
              profile: 'some.profile'
            ).once

          subject
        end
      end
    end
  end
end
