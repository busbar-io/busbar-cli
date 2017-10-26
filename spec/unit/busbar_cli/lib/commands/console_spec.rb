require 'spec_helper'

RSpec.describe Commands::Console do
  describe '#console' do
    class DummyClass < Thor
      include Commands::Console
    end

    subject { my_cli.console('app_id', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Console).to receive(:call).with('app_id', 'environment_name')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(my_cli).to receive(:options).and_return(
        double(:options, profile: 'some.profile')
      )
    end

    it "runs an app's console" do
      expect(Services::Console).to receive(:call).with('app_id', 'environment_name').once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
