require 'spec_helper'

RSpec.describe SettingsRepository do
  let(:environment) { instance_double(Environment, app_id: 'some_app', name: 'staging') }

  describe '#by_environment' do
    subject { described_class.by_environment(environment: environment) }

    before do
      allow(Request).to receive(:get)
        .with('/apps/some_app/environments/staging/settings')
        .and_return(
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: '{"data":[{"key":"some_setting","value":"some_value"}]}'
          )
        )
    end

    it 'creates a new setting of each app fetched' do
      expect(Setting).to receive(:new)
        .with(
          'key' => 'some_setting',
          'value' => 'some_value'
        ).once

      subject
    end

    context 'when the app can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging/settings')
          .and_return(
            instance_double(Net::HTTPNotFound, code: '404')
          )
      end

      it 'returns nil' do
        expect(subject).to eq([])
      end
    end
  end

  describe '#get' do
    subject do
      described_class.get(environment: environment, setting_key: 'some_setting')
    end

    before do
      allow(Request).to receive(:get)
        .with('/apps/some_app/environments/staging/settings/SOME_SETTING')
        .and_return(
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: '{"data":{"key":"some_setting","value":"some_value"}}'
          )
        )
    end

    it 'returns a new environment with the information retrieved' do
      expect(subject).to have_attributes(
        key: 'some_setting',
        value: 'some_value',
        app_id: 'some_app',
        environment_name: 'staging'
      )
    end

    context 'when the app or environment can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging/settings/SOME_SETTING')
          .and_return(
            instance_double(Net::HTTPNotFound, code: '404')
          )
      end

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#set' do
    subject { described_class.set(environment: environment, settings: settings, deploy: true) }

    let(:settings) do
      {
        setting_1: 'value_1',
        setting_2: 'value_2'
      }
    end

    before do
      allow(Request).to receive(:put)
        .with('/apps/some_app/environments/staging/settings/bulk', settings: settings, deploy: true)
        .and_return(
          instance_double(Net::HTTPOK, code: '200')
        )
    end

    it 'sends a post with the environment\'s params' do
      expect(Request).to receive(:put)
        .with('/apps/some_app/environments/staging/settings/bulk', settings: settings, deploy: true)
        .once

      subject
    end

    it 'checks if the status of the response is 200' do
      expect(subject).to eq(true)
    end
  end

  describe '#unset' do
    subject { described_class.destroy(setting: setting) }

    let(:setting) do
      instance_double(Setting, key: 'some_setting', environment_name: 'staging', app_id: 'some_app')
    end

    before do
      allow(Request).to receive(:delete)
        .with('/apps/some_app/environments/staging/settings/SOME_SETTING')
        .and_return(
          instance_double(Net::HTTPNoContent, code: '204')
        )
    end

    it 'destroys the setting' do
      expect(Request).to receive(:delete)
        .with('/apps/some_app/environments/staging/settings/SOME_SETTING')
        .once

      subject
    end

    it 'checks if the status of the response is 204' do
      expect(subject).to eq(true)
    end
  end
end
