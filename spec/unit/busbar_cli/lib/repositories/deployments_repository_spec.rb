require 'spec_helper'

RSpec.describe DeploymentsRepository do
  describe '#create' do
    subject { described_class.create('some_app', 'staging', params) }

    let(:params) { { branch: 'master', build: true } }

    before do
      allow(Request).to receive(:post)
        .with(
          '/apps/some_app/environments/staging/deployments',
          params
        ).and_return(instance_double(Net::HTTPCreated, code: '201'))
    end

    it 'deploys the environment' do
      expect(Request).to receive(:post)
        .with(
          '/apps/some_app/environments/staging/deployments',
          params
        ).once

      subject
    end

    it 'checks if the response status is 201' do
      expect(subject).to eq(true)
    end
  end
end
