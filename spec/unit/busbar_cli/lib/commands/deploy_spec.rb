require 'spec_helper'

RSpec.describe Commands::Deploy do
  describe '#deploy' do
    class DummyClass < Thor
      include Commands::Deploy
    end

    let(:my_cli) { DummyClass.new }

    let(:environment) { instance_double(Environment) }

    before do
      my_cli.options = double(:options, log: true, profile: 'some.profile')

      allow(Services::LatestBuildLogs).to receive(:call)
      allow(Services::Deploy).to receive(:call)
      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)
      allow(Services::Kube).to receive(:configure_temporary_profile)
    end

    context 'with branch param given' do
      subject { my_cli.deploy('app_id', 'environment_name', 'develop') }

      it 'deploys an environment using the given branch' do
        expect(Services::Deploy).to receive(:call)
          .with('app_id', 'environment_name', 'develop')
          .once

        subject
      end

      it 'prints the deployment logs' do
        expect(Services::LatestBuildLogs).to receive(:call).with(environment).once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'with no branch param given' do
      subject { my_cli.deploy('app_id', 'environment_name') }

      it 'deploys an environment using the default branch' do
        expect(Services::Deploy).to receive(:call)
          .with('app_id', 'environment_name', DEFAULT_BRANCH)
          .once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'with options --log set to false' do
      subject { my_cli.deploy('app_id', 'environment_name', 'develop') }

      before do
        my_cli.options = double(:options, log: false, profile: 'some.profile')
      end

      it 'deploys an environment using the given branch' do
        expect(Services::Deploy).to receive(:call)
          .with('app_id', 'environment_name', 'develop')
          .once

        subject
      end

      it 'does not print the deployment logs' do
        expect(Services::LatestBuildLogs).to_not receive(:call)

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end
  end
end
