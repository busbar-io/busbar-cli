require 'spec_helper'

RSpec.describe Commands::Scale do
  describe '#scale' do
    class DummyClass < Thor
      include Commands::Scale
    end

    subject { my_cli.scale('app_id', 'environment_name', 'web', '2') }

    let(:my_cli) { DummyClass.new }
    let(:component) { instance_double(Component) }

    before do
      allow(Services::Scaler).to receive(:call)

      allow(Component).to receive(:new)
        .with(app_id: 'app_id', environment_name: 'environment_name', type: 'web')
        .and_return(component)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'scales the component' do
      expect(Services::Scaler).to receive(:call).with(component, '2').once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
