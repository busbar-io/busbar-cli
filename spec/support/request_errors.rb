RSpec.shared_examples 'request errors' do |method, body|
  let(:no_connection_error_message) do
    "No connection could be established with the Busbar server (http://busbar.fake.profile).\n" \
    'You may need to connect to a VPN to access it.'
  end

  let(:internal_error_message) do
    "Internal error on Busbar server (http://busbar.fake.profile).\n" \
     "URI: http://busbar.fake.profile/apps/some_app\n" \
     "Body: #{body}\n" \
     'Response code: 500'
  end

  let(:error_503) do
    "(http://busbar.fake.profile) service is unavailable.\n" \
    "URI: http://busbar.fake.profile/apps/some_app\n" \
    'Response code: 503'
  end

  let(:error_504) do
    "(http://busbar.fake.profile) gateway Time-out.\n" \
    "URI: http://busbar.fake.profile/apps/some_app\n" \
    'Response code: 504'
  end

  let(:body) { '' }

  before do
    stub_request(method, 'http://busbar.fake.profile/apps/some_app')
      .to_return(status: status, body: '', headers: {})
  end

  context 'when an socket error happens' do
    let(:status) { 200 }

    before do
      allow(Net::HTTP).to receive(:start).and_raise(SocketError)
    end

    it 'prints an error message' do
      begin
        subject
      rescue SystemExit
        expect(described_class).to have_received(:puts)
          .with(no_connection_error_message)
          .once
      end
    end

    it 'exits with code 0' do
      expect(-> { subject }).to exit_with_code(0)
    end
  end

  context 'when the response status is 500' do
    let(:status) { 500 }

    it 'prints an error message' do
      begin
        subject
      rescue SystemExit
        expect(Request).to have_received(:puts)
          .with(internal_error_message)
          .once
      end
    end

    it 'exits with code 0' do
      expect(-> { subject }).to exit_with_code(0)
    end
  end

  context 'when the respose status is 503' do
    let(:status) { 503 }

    it 'prints an error message' do
      begin
        subject
      rescue SystemExit
        expect(described_class).to have_received(:puts)
          .with(error_503)
          .once
      end
    end

    it 'exits with code 0' do
      expect(-> { subject }).to exit_with_code(0)
    end
  end

  context 'when the respose status is 504' do
    let(:status) { 504 }

    it 'prints an error message' do
      begin
        subject
      rescue SystemExit
        expect(described_class).to have_received(:puts)
          .with(error_504)
          .once
      end
    end

    it 'exits with code 0' do
      expect(-> { subject }).to exit_with_code(0)
    end
  end
end
