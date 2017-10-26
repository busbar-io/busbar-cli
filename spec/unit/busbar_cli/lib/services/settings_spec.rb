require 'spec_helper'

RSpec.describe Services::Settings do
  let(:environment) { instance_double(Environment) }
  let(:setting) do
    instance_double(
      Setting,
      key: 'some_setting',
      value: 'some_value',
      app_id: 'some_app',
      environment_name: 'staging'
    )
  end

  describe '#get' do
    subject { described_class.get(environment, 'some_setting') }

    before do
      allow(SettingsRepository).to receive(:get)
        .with(environment: environment, setting_key: 'some_setting')
        .and_return(setting)
    end

    it 'prints the setting' do
      expect(Printer).to receive(:print_resource).with(setting).once

      subject
    end
  end

  describe '#set' do
    subject do
      described_class.set(
        environment,
        [
          'some_setting=some_value',
          'some_other_setting=some_other_value',
          'invalid_setting'
        ],
        true
      )
    end

    before do
      allow(SettingsRepository).to receive(:set)
        .with(
          environment: environment,
          settings: {
            'SOME_SETTING' => 'some_value',
            'SOME_OTHER_SETTING' => 'some_other_value'
          },
          deploy: true
        ).and_return(variables_set?)
    end

    let(:variables_set?) { true }

    it 'prints the result of the set' do
      expect(Printer).to receive(:print_result)
        .with(
          result: variables_set?,
          success_message: 'Settings updated with success',
          failure_message: 'Error while updating the settings. ' \
                           'Please check its existence (and of its app)'
        ).once

      subject
    end
  end

  describe '#by_environment' do
    subject { described_class.by_environment(environment) }

    before do
      allow(described_class).to receive(:puts)
      allow(SettingsRepository).to receive(:by_environment)
        .with(environment: environment)
        .and_return(
          [
            instance_double(Setting, key: 'SOME_SETTING', value: 'some_value'),
            instance_double(Setting, key: 'SOME_OTHER_SETTING', value: 'some_other_value')
          ]
        )
    end

    it 'prints each setting of the environment' do
      expect(described_class).to receive(:puts).with('SOME_SETTING=some_value')
      expect(described_class).to receive(:puts).with('SOME_OTHER_SETTING=some_other_value')

      subject
    end
  end

  describe '#unset' do
    subject { described_class.unset(setting) }

    let(:setting_destroyed?) { true }

    before do
      allow(SettingsRepository).to receive(:destroy)
        .with(setting: setting)
        .and_return(setting_destroyed?)
    end

    it 'prints the result of the unset' do
      expect(Printer).to receive(:print_result)
        .with(
          result: setting_destroyed?,
          success_message: 'Setting "SOME_SETTING" was deleted '\
                          'from some_app\'s staging environment',
          failure_message: 'Error while destroying setting ' \
                           'some_app\'s staging environment. Please check your input'
        ).once

      subject
    end
  end
end
