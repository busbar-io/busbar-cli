require 'spec_helper'

RSpec.describe Commands::Show do
  describe '#show' do
    class DummyClass < Thor
      include Commands::Show
    end

    let(:my_cli) { DummyClass.new }

    before do
      allow(Printer).to receive(:print_resource)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    context 'when no environment is not given' do
      subject { my_cli.show('app_id') }

      before do
        allow(AppsRepository).to receive(:find)
          .with(app_id: 'app_id')
          .and_return(app)

        allow(Printer).to receive(:print_resource)
          .with(app)
      end

      let(:app) { instance_double(App) }

      it 'prints the app' do
        expect(Printer).to receive(:print_resource)
          .with(app)
          .once

        subject
      end
    end

    context 'when a environment is given' do
      subject { my_cli.show('app_id', 'environment_name') }

      before do
        allow(EnvironmentsRepository).to receive(:find)
          .with(app_id: 'app_id', environment_name: 'environment_name')
          .and_return(environment)

        allow(Printer).to receive(:print_resource)
          .with(environment)
      end

      let(:environment) { instance_double(Environment) }

      it 'prints the environment' do
        expect(Printer).to receive(:print_resource)
          .with(environment)
          .once

        subject
      end
    end
  end
end
