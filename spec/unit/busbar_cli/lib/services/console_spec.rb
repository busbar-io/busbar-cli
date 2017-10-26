require 'spec_helper'

RSpec.describe Services::Console do
  describe '#call' do
    subject { described_class.call('app_id', 'environment_name') }

    let(:environment) do
      instance_double(
        Environment,
        name: 'environment_name',
        id: 'environment_id',
        app_id: 'app_id',
        namespace: 'environment_namespace',
        settings: {
          'SETTING_1' => 'VALUE_1',
          'SETTING_2' => 'VALUE_2'
        }
      )
    end

    before do
      allow(Services::Kube).to receive(:setup)

      allow(EnvironmentsRepository).to receive(:find)
        .with(environment_name: 'environment_name', app_id: 'app_id')
        .and_return(environment)

      allow_any_instance_of(described_class).to receive(:`)
        .with('tput lines')
        .and_return("44\n")

      allow_any_instance_of(described_class).to receive(:`)
        .with('tput cols')
        .and_return("180\n")

      allow(Kernel).to receive(:exec)
    end

    it 'run kube setup' do
      expect(Services::Kube).to receive(:setup)
      subject
    end

    it 'fetch environment data' do
      expect(EnvironmentsRepository).to receive(:find).with(environment_name: 'environment_name', app_id: 'app_id')
      subject
    end

    context 'when the environment can not be found' do
      let(:environment) { nil }

      it 'print a message about it' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('Environment or app not found. Please check your input')

        begin
          subject
        rescue SystemExit # rubocop:disable Lint/HandleExceptions
        end
      end

      it 'print a message about it and exit with status 0' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('Environment or app not found. Please check your input')

        expect(-> { subject }).to exit_with_code(0)
      end
    end

    it 'run a container with the proper settings' do
      expect(Kernel).to receive(:exec)
        .with(
          "#{KUBECTL} run --context=busbar_profile " \
          "app_id-environment_name-console-#{Time.now.utc.to_i} " \
                "--rm --image=#{DOCKER_PRIVATE_REGISTRY}/environment_id:latest --stdin --tty " \
                '--restart=Never --image-pull-policy=Always --namespace=environment_namespace -- ' \
          '/usr/bin/env LINES=44 COLUMNS=180 ' \
          "TERM=#{ENV['TERM']} SETTING_1='VALUE_1' SETTING_2='VALUE_2' /bin/bash -li"
        )
      subject
    end
  end
end
