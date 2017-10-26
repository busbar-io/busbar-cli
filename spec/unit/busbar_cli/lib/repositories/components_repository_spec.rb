require 'spec_helper'

RSpec.describe ComponentsRepository do
  let(:component) do
    instance_double(Component, app_id: 'some_app', environment_name: 'staging', type: 'web')
  end

  before do
    allow(Request).to receive(:put).and_return(
      instance_double(Net::HTTPAccepted, code: '202')
    )
  end

  describe '#resize' do
    subject { described_class.resize(component: component, node_type: '1x.standard') }

    it 'resizes the component' do
      expect(Request).to receive(:put)
        .with(
          '/apps/some_app/environments/staging/components/web/resize',
          node_id: '1x.standard'
        ).once

      subject
    end

    it 'checks if the response status is 202' do
      expect(subject).to eq(true)
    end
  end

  describe '#scale' do
    subject { described_class.scale(component: component, scale: 10) }

    it 'scales the component' do
      expect(Request).to receive(:put)
        .with(
          '/apps/some_app/environments/staging/components/web/scale',
          scale: 10
        ).once

      subject
    end

    it 'checks if the response status is 202' do
      expect(subject).to eq(true)
    end
  end

  describe '#log_for' do
    subject { described_class.log_for(component: component, size: 1) }

    before do
      allow(Request).to receive(:get)
        .with('/apps/some_app/environments/staging/components/web/log?size=1')
        .and_return(
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: '{"data":{"content":"this is the content of the log"}}'
          )
        )

      allow(ComponentLog).to receive(:new)
        .with('content' => 'this is the content of the log')
        .and_return(component_log)
    end

    let(:component_log) { instance_double(ComponentLog) }

    it 'returns a component log for the given component' do
      expect(subject).to eq(component_log)
    end

    context 'when the component can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging/components/web/log?size=1')
          .and_return(
            instance_double(Net::HTTPNotFound, code: '404')
          )
      end

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
