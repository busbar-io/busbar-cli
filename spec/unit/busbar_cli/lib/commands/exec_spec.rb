require 'spec_helper'

RSpec.describe Commands::Exec do
  describe '#exec' do
    class DummyClass < Thor
      include Commands::Exec
    end

    let(:pod) { 'busbar-web-123' }
    let(:command) { 'rails console' }
    let(:pod_environment) { 'busbar' }
    let(:namespace) { 'busbar' }

    subject { my_cli.exec(pod, pod_environment, command) }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(Kernel).to receive(:exec)
    end

    context 'with --namespace option' do
      it 'calls the exec command for the given pod' do
        my_cli.options = double(:options, profile: 'current.profile', namespace: namespace)

        expect(Kernel).to receive(:exec)
          .with(
            "#{KUBECTL} --namespace #{namespace} --context=current.profile exec -ti #{pod} #{command}"
          )
        subject
      end
    end

    it 'uses the profile from the options' do
      my_cli.options = double(:options, profile: 'current.profile', namespace: namespace)

      expect(Services::Kube).to receive(:configure_temporary_profile).with('current.profile').once

      subject
    end
  end
end
