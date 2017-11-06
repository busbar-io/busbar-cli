require 'spec_helper'

RSpec.describe Services::AppConfig::Reseter do
  describe '#call' do
    subject { described_class.call }

    let(:deployment) { true }

    before do
      allow(Services::AppConfig).to receive(:reset_all)
      allow(Confirmator).to receive(:confirm)
      allow(described_class).to receive(:puts)
    end

    it 'resets configs' do
      begin
        subject
      rescue SystemExit
        expect(Services::AppConfig).to have_received(:reset_all).once
      end
    end

    it 'prints a message about reseting the configs' do
      begin
        subject
      rescue SystemExit
        expect(described_class).to have_received(:puts)
          .with('Application configuration reset with success.').once
      end
    end

    it 'asks the user for confirmation' do
      begin
        subject
      rescue SystemExit
        expect(Confirmator).to have_received(:confirm).with(
          question: 'Are you sure you want to reset all of your application configs? ' \
                    'This action is irreversible.',
          exit_message: 'Exiting without resetting application configs.'
        )
      end
    end
  end
end
