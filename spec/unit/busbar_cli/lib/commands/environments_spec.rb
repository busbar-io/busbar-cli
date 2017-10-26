require 'spec_helper'

RSpec.describe Commands::Environments do
  describe '#environments' do
    class DummyClass < Thor
      include Commands::Environments
    end

    subject { my_cli.environments('app_id') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Environments).to receive(:call)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it "retrieves all the apps's environments" do
      expect(Services::Environments).to receive(:call).with('app_id').once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
