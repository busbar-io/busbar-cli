require 'spec_helper'

RSpec.describe Services::ComponentLogs do
  describe '#call' do
    subject { described_class.call(component: component, size: 100) }

    before do
      allow(ComponentsRepository).to receive(:log_for)
        .with(component: component, size: 100)
        .and_return(component_log)
    end

    let(:component) { instance_double(Component) }
    let(:component_log) { instance_double(ComponentLog) }

    it 'prints the logs from the given component' do
      expect(Printer).to receive(:print_resource).with(component_log).once

      subject
    end
  end
end
