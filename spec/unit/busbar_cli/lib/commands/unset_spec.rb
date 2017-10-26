require 'spec_helper'

RSpec.describe Commands::Unset do
  describe '#set' do
    class DummyClass < Thor
      include Commands::Unset
    end

    let(:my_cli) { DummyClass.new }

    subject { my_cli.unset('app_id', 'environment_name', 'setting') }

    let(:setting) { instance_double(Setting) }

    before do
      allow(Services::Settings).to receive(:unset)

      allow(Setting).to receive(:new)
        .with(app_id: 'app_id', environment_name: 'environment_name', key: 'setting')
        .and_return(setting)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'unsets the given variable' do
      expect(Services::Settings).to receive(:unset).with(setting).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
