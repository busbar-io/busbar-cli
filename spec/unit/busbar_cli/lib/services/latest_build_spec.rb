require 'spec_helper'

RSpec.describe Services::LatestBuild do
  describe '#call' do
    subject { described_class.call(environment) }

    let(:environment) { instance_double(Environment, name: 'staging', app_id: 'app_id') }
    let(:build) { instance_double(Build) }

    before do
      allow(BuildsRepository).to receive(:latest).with(environment).and_return(build)
    end

    it 'prints the latest build of the given environment' do
      expect(Printer).to receive(:print_resource).with(build).once

      subject
    end
  end
end
