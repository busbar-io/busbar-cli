require 'spec_helper'

RSpec.describe Services::AppConfig::Displayer do
  describe '#call' do
    it 'displays the current config and usage' do
      expect do
        described_class.call
      end.to output('
Usage:
  rspec app-config

Options:
  [--app=APP]                  # App to be used in further commands
  [--environment=ENVIRONMENT]  # Environment to be used in further commands
  [--component=COMPONENT]      # Component to be used in further commands
  [--reset], [--no-reset]      # Reset all of your configs
  [--unset=UNSET]              # Config to be unset

Local application CLI configuration.

Your current application config is:
').to_stdout
    end
  end
end
