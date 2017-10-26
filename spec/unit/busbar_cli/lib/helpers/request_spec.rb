require 'spec_helper'

RSpec.describe Request do
  before do
    allow(Services::Kube).to receive(:current_profile).and_return('fake.profile')
    allow(described_class).to receive(:puts)
  end

  describe '#get' do
    subject { described_class.get('/apps/some_app') }

    it_behaves_like 'request errors', :get, ''

    it 'returns the server response' do
      stub_request(:get, 'http://busbar.fake.profile/apps/some_app')
        .to_return(status: 200, body: '', headers: {})

      expect(subject).to be_an_instance_of(Net::HTTPOK)
    end
  end

  describe '#post' do
    subject { described_class.post('/apps/some_app', id: 'some_app', repository: 'somerepo.git') }

    it_behaves_like 'request errors', :post, '{"id":"some_app","repository":"somerepo.git"}'

    it 'returns the server response' do
      stub_request(:post, 'http://busbar.fake.profile/apps/some_app')
        .to_return(status: 201, body: '', headers: {})

      expect(subject).to be_an_instance_of(Net::HTTPCreated)
    end
  end

  describe '#put' do
    subject { described_class.put('/apps/some_app', id: 'some_app', repository: 'somerepo.git') }

    it_behaves_like 'request errors', :put, '{"id":"some_app","repository":"somerepo.git"}'

    it 'returns the server response' do
      stub_request(:put, 'http://busbar.fake.profile/apps/some_app')
        .to_return(status: 202, body: '', headers: {})

      expect(subject).to be_an_instance_of(Net::HTTPAccepted)
    end
  end

  describe '#delete' do
    subject { described_class.delete('/apps/some_app') }

    it_behaves_like 'request errors', :delete, ''

    it 'returns the server response' do
      stub_request(:delete, 'http://busbar.fake.profile/apps/some_app')
        .to_return(status: 204, body: '', headers: {})

      expect(subject).to be_an_instance_of(Net::HTTPNoContent)
    end
  end
end
