require 'spec_helper'

RSpec.describe Services::Scaler do
  describe '#call' do
    subject { described_class.call(component, 2) }

    let(:component) do
      instance_double(
        Component,
        app_id: 'app_id',
        environment_name: 'environment_name',
        type: 'web'
      )
    end

    let(:scaled) { true }

    before do
      allow(ComponentsRepository).to receive(:scale)
        .with(component: component, scale: 2)
        .and_return(scaled)
    end

    it 'prints the result of the component scaling' do
      expect(Printer).to receive(:print_result)
        .with(
          result: scaled,
          success_message: 'Component web of app_id ' \
                           'environment_name was scheduled for scaling',
          failure_message: 'Error scaling component web of app_id environment_name.' \
                           'Please check its existence (and of its app/environment)'
        ).once

      subject
    end
  end
end
