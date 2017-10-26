require 'spec_helper'

RSpec.describe Services::EnvironmentDestroyer do
  describe '#call' do
    subject { described_class.call(environment) }

    let(:environment) { instance_double(Environment, name: 'staging', app_id: 'app_id') }

    before do
      allow_any_instance_of(described_class).to receive(:puts)
      allow(EnvironmentsRepository).to receive(:destroy)
      allow(Confirmator).to receive(:confirm)
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')
    end

    it 'asks for confirmation' do
      expect(Confirmator).to receive(:confirm)
        .with(
          question: 'Are you sure you want to destroy the environment staging of app_id ' \
                    'on profile current.profile? ' \
                    'This action is irreversible.'
        ).once
      subject
    end

    it 'destroys the environment' do
      expect(EnvironmentsRepository).to receive(:destroy).with(environment: environment).once

      subject
    end

    it 'prints a message about the environment destruction' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('Environment app_id staging is scheduled for destruction')
        .once

      subject
    end
  end
end
