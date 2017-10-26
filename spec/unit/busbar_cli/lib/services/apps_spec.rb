require 'spec_helper'

RSpec.describe Services::Apps do
  describe '#call' do
    subject { described_class.call }

    before do
      allow(AppsRepository).to receive(:all).and_return(apps)
      allow(described_class).to receive(:puts)
    end

    let(:app_1) do
      instance_double(
        App,
        id: 'app_1',
        buildpack_id: 'ruby',
        environment_list: 'staging / production'
      )
    end

    let(:app_2) do
      instance_double(
        App,
        id: 'app_2',
        buildpack_id: 'ruby',
        environment_list: 'staging / production'
      )
    end

    let(:app_3) do
      instance_double(
        App,
        id: 'app_3',
        buildpack_id: 'ruby',
        environment_list: 'staging / production'
      )
    end

    let(:apps) do
      [app_1, app_2, app_3]
    end

    it 'prints all the apps' do
      expect(described_class).to receive(:puts)
        .with('app_1 (ruby) - staging / production')
      expect(described_class).to receive(:puts)
        .with('app_2 (ruby) - staging / production')
      expect(described_class).to receive(:puts)
        .with('app_3 (ruby) - staging / production')

      subject
    end
  end
end
