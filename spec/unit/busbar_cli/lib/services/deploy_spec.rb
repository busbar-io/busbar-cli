require 'spec_helper'

RSpec.describe Services::Deploy do
  describe '#call' do
    subject { described_class.call('app_id', 'environment_name', 'master') }

    let(:deployment) { true }

    before do
      allow(DeploymentsRepository).to receive(:create)
        .with('app_id', 'environment_name', branch: 'master', build: true)
        .and_return(deployment)
    end

    it 'prints the result of a deployment of the given environment and branch' do
      expect(Printer).to receive(:print_result)
        .with(
          result: deployment,
          success_message: 'Deployment scheduled',
          failure_message: 'Error while deploying the environment. ' \
                           'Please check its existence (and of its app)'
        )

      subject
    end
  end
end
