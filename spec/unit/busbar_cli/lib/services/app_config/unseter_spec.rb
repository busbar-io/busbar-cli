require 'spec_helper'

RSpec.describe Services::AppConfig::Unseter do
  describe '#call' do
    subject { described_class.call('component') }

    before do
      allow(Services::AppConfig).to receive(:delete)
      allow(described_class).to receive(:puts)
    end

    it 'unsets the given config' do
      expect(Services::AppConfig).to receive(:delete).with('component').once

      subject
    end

    it 'prints a message about reseting the configs' do
      expect(described_class).to receive(:puts)
        .with('component removed from local config.').once

      subject
    end

    context 'when the given config is not available' do
      subject { described_class.call('invalid_config') }

      it 'warns the user that the config is invalid' do
        expect(described_class).to receive(:puts)
          .with('invalid_config is not a valid config key. The valid keys are:').once

        subject
      end

      it 'shows the valid configs to the user' do
        expect(described_class).to receive(:puts)
          .with(AVAILABLE_CONFIGS.join(' / ')).once

        subject
      end
    end
  end
end
