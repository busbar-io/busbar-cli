require 'spec_helper'

RSpec.describe Commands::AppConfig do
  describe '#app_config' do
    class DummyClass < Thor
      include Commands::AppConfig
    end

    subject { my_cli.app_config }

    let(:my_cli) { DummyClass.new }

    before do
      my_cli.options = double(
        :options,
        {
          empty?: false,
          environment: nil,
          app: nil,
          component: nil,
          reset: nil,
          unset: nil
        }.merge(options)
      )

      allow(my_cli).to receive(:puts)
      allow(Services::AppConfig).to receive(:set)
      allow(Services::AppConfig::Displayer).to receive(:call)
    end

    context 'with no options' do
      let(:options) { { empty?: true } }

      it 'displays the curent config' do
        expect(Services::AppConfig::Displayer).to receive(:call).once

        subject
      end
    end

    context 'with --app option' do
      let(:options) { { app: 'some_app' } }

      it 'sets the app in the config' do
        expect(Services::AppConfig).to receive(:set).with('app', 'some_app').once

        subject
      end

      it 'prints a message about setting the app config' do
        expect(my_cli).to receive(:puts).with('app some_app set').once

        subject
      end
    end

    context 'with --environment option' do
      let(:options) { { environment: 'staging' } }

      it 'sets the environment in the config' do
        expect(Services::AppConfig).to receive(:set).with('environment', 'staging').once

        subject
      end

      it 'prints a message about setting the environment config' do
        expect(my_cli).to receive(:puts).with('environment staging set').once

        subject
      end
    end

    context 'with --component option' do
      let(:options) { { component: 'web' } }

      it 'sets the component in the config' do
        expect(Services::AppConfig).to receive(:set).with('component', 'web').once

        subject
      end

      it 'prints a message about setting the component config' do
        expect(my_cli).to receive(:puts).with('component web set').once

        subject
      end
    end

    context 'with --reset option' do
      let(:options) { { reset: true } }

      it 'resets the configs' do
        expect(Services::AppConfig::Reseter).to receive(:call).once

        subject
      end
    end

    context 'with --unset option' do
      let(:options) { { unset: 'component' } }

      it 'unsets the given config' do
        expect(Services::AppConfig::Unseter).to receive(:call).with('component').once

        subject
      end
    end
  end
end
