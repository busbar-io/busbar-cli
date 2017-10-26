require 'spec_helper'

RSpec.describe Commands::Version do
  describe '#version' do
    class DummyClass < Thor
      include Commands::Version
    end

    let(:my_cli) { DummyClass.new }

    before do
      allow(my_cli).to receive(:puts)
      allow(Services::LatestBuild).to receive(:call)
      my_cli.options = double(:options, profile: 'some.profile')
    end

    subject { my_cli.version('app_id', 'environment_name') }

    let(:environment) { instance_double(Environment) }
    let(:latest_build) { instance_double(Build) }

    before do
      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)

      allow(Services::Kube).to receive(:configure_temporary_profile)
    end

    it 'prints its latest build' do
      expect(Services::LatestBuild).to receive(:call).with(environment).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
