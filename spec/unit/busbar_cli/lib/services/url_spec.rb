require 'spec_helper'

RSpec.describe Services::Url do
  let(:environment) do
    instance_double(
      Environment,
      app_id: 'some_app',
      name: 'staging',
      settings: { 'PORT' => 9292 }
    )
  end

  describe '#internal' do
    subject { described_class.internal(environment) }

    context 'when the environment has a PORT setting' do
      it 'returns the internal URL of the environment with port defined in the settings' do
        expect(subject).to eq('http://some_app.staging:9292')
      end
    end

    context 'when the environment does not have a PORT setting' do
      let(:environment) do
        instance_double(
          Environment,
          app_id: 'some_app',
          name: 'staging',
          settings: {}
        )
      end

      it 'returns the internal URLof the environment with default port' do
        expect(subject).to eq('http://some_app.staging:8080')
      end
    end
  end

  describe '#ingress' do
    subject { described_class.ingress(environment) }

    before do
      allow(Services::Kube).to receive(:current_profile)
        .and_return('current.profile')
    end

    it 'returns the ingress url of the environment' do
      expect(subject).to eq('http://some_app.staging.current.profile')
    end
  end

  describe '#public' do
    subject { described_class.public(environment) }

    before do
      allow(Services::Kube).to receive(:public_address_info_for)
        .with(environment: environment)
        .and_return(address: 'some_app_url', port: '8080')
    end

    it 'returns the public url of the environment' do
      expect(subject).to eq('http://some_app_url:8080')
    end
  end
end
