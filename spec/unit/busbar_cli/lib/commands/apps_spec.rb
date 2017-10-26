require 'spec_helper'

RSpec.describe Commands::Apps do
  describe '#apps' do
    class DummyClass < Thor
      include Commands::Apps
    end

    subject { my_cli.apps }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Apps).to receive(:call)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'retrieves all the apps' do
      expect(Services::Apps).to receive(:call).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
