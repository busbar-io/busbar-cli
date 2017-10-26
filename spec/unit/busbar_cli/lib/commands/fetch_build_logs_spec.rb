require 'spec_helper'

RSpec.describe Commands::FetchBuildLogs do
  describe '#fetch_build_logs' do
    class DummyClass < Thor
      include Commands::FetchBuildLogs
    end

    subject { my_cli.fetch_build_logs('app_id', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    let(:environment) do
      instance_double(
        Environment,
        app_id: 'app_id',
        name: 'environment_name'
      )
    end

    before do
      allow(Environment).to receive(:new)
        .with(app_id: 'app_id', name: 'environment_name')
        .and_return(environment)

      allow(Services::LatestBuildLogs).to receive(:call)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it "retrieves all the environment's latest build logs" do
      expect(Services::LatestBuildLogs).to receive(:call).with(environment).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
