require 'spec_helper'

RSpec.describe Commands::Resize do
  describe '#resize' do
    class DummyClass < Thor
      include Commands::Resize
    end

    let(:my_cli) { DummyClass.new }

    before do
      allow(Printer).to receive(:print_result)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    context 'when a component_type is given' do
      subject { my_cli.resize('app_id', 'environment_name', 'web', '1x.standard') }

      let(:component) { instance_double(Component) }

      before do
        allow(Component).to receive(:new)
          .with(app_id: 'app_id', environment_name: 'environment_name', type: 'web')
          .and_return(component)

        allow(ComponentsRepository).to receive(:resize)
          .with(component: component, node_type: '1x.standard')
          .and_return(true)
      end

      it 'resizes the component' do
        expect(ComponentsRepository).to receive(:resize)
          .with(component: component, node_type: '1x.standard')
          .once

        subject
      end

      it 'prints the result of the resizing' do
        expect(Printer).to receive(:print_result)
          .with(
            result: true,
            success_message: 'Resource scheduled for resizing',
            failure_message: 'Error while resizing the resource. ' \
                             'Please check its existence (and of its app)'
          )
          .once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'when a component_type is not given' do
      subject { my_cli.resize('app_id', 'environment_name', '1x.standard') }

      let(:environment) { instance_double(Environment) }

      before do
        allow(Environment).to receive(:new)
          .with(app_id: 'app_id', name: 'environment_name')
          .and_return(environment)

        allow(EnvironmentsRepository).to receive(:resize)
          .with(environment: environment, node_type: '1x.standard')
          .and_return(true)
      end

      it 'resizes the environment' do
        expect(EnvironmentsRepository).to receive(:resize)
          .with(environment: environment, node_type: '1x.standard')
          .once

        subject
      end

      it 'prints the result of the resizing' do
        expect(Printer).to receive(:print_result)
          .with(
            result: true,
            success_message: 'Resource scheduled for resizing',
            failure_message: 'Error while resizing the resource. ' \
                             'Please check its existence (and of its app)'
          )
          .once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end
  end
end
