require 'spec_helper'

RSpec.describe Services::AppDestroyer do
  describe '#call' do
    subject { described_class.call(app) }

    let(:app) { instance_double(App, id: 'app_id') }

    before do
      allow_any_instance_of(described_class).to receive(:puts)
      allow(AppsRepository).to receive(:destroy)
      allow(Confirmator).to receive(:confirm)
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')
    end

    it 'asks for confirmation' do
      expect(Confirmator).to receive(:confirm)
        .with(
          question: 'Are you sure you want to destroy the app app_id ' \
                    'and its enviroments on profile current.profile? ' \
                    'This action is irreversible.'
        ).once
      subject
    end

    it 'destroys the app' do
      expect(AppsRepository).to receive(:destroy).with(app: app).once

      subject
    end

    it 'prints a message about the app destruction' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('App app_id is scheduled for destruction')
        .once

      subject
    end
  end
end
