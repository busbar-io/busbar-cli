require 'spec_helper'

RSpec.describe Services::Logs do
  describe '#call' do
    subject do
      described_class.call(
        container_id: 'some_container',
        environment_name: 'environment_name',
        since: '0'
      )
    end

    before do
      allow(Services::Kube).to receive(:setup)
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')
      allow(Kernel).to receive(:exec)
    end

    it 'ensures kubectl dependencies are installed' do
      expect(Services::Kube).to receive(:setup).once

      subject
    end

    it "runs the commands to fetch the container's logs" do
      expect(Kernel).to receive(:exec)
        .with(
          "#{KUBECTL} --context=current.profile " \
          'logs -f --since=0 some_container -n environment_name'
        ).once

      subject
    end
  end
end
