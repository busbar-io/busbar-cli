require 'spec_helper'

RSpec.describe Commands::Logs do
  describe '#logs' do
    class DummyClass < Thor
      include Commands::Logs
    end

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Logs).to receive(:call)
      allow(Services::ComponentLogs).to receive(:call)

      allow(AppsRepository).to receive(:find)
        .with(app_id: 'app_id')
        .and_return(app)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = {
        'since' => '0',
        'size' => '10',
        'profile' => 'some.profile'
      }
    end

    let(:app) { nil }

    context 'when getting logs from a container' do
      subject { my_cli.logs('container_id', 'environment_name') }

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end

      it 'returns the logs of the given container' do
        expect(Services::Logs).to receive(:call)
          .with(
            container_id: 'container_id',
            environment_name: 'environment_name',
            since: '0'
          ).once

        subject
      end
    end

    context 'when getting logs from an component (web, worker, etc)' do
      subject { my_cli.logs('app_id', 'environment_name', 'web') }

      before do
        allow(Component).to receive(:new)
          .with(app_id: 'app_id', environment_name: 'environment_name', type: 'web')
          .and_return(component)
      end

      let(:component) { instance_double(Component) }
      let(:app) { instance_double(App) }

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end

      it 'returns the log of the component' do
        expect(Services::ComponentLogs).to receive(:call)
          .with(component: component, size: 10)
          .once

        subject
      end

      context 'when the given app can not be found' do
        let(:app) { nil }

        it 'assumes that the resource is a container' do
          expect(Services::Logs).to receive(:call)
            .with(container_id: 'app_id', environment_name: 'environment_name', since: '0')
            .once

          subject
        end
      end
    end
  end
end
