require 'spec_helper'

RSpec.describe DatabasesRepository do
  describe '#all' do
    subject { described_class.all }

    before do
      allow(Request).to receive(:get)
        .with('/databases/')
        .and_return(
          instance_double(
            Net::HTTPOK,
            body: '{"data":[{"id":"db","namespace":"staging","size":"10Gb",'\
                  '"type":"mongo","created_at":"2017-03-24T00:21:24Z",'\
                  '"updated_at":"2017-03-24T00:21:24Z"}]}'
          )
        )
    end

    it 'creates a new database of each app fetched' do
      expect(Database).to receive(:new)
        .with(
          'id' => 'db',
          'size' => '10Gb',
          'namespace' => 'staging',
          'type' => 'mongo',
          'created_at' => '2017-03-24T00:21:24Z',
          'updated_at' => '2017-03-24T00:21:24Z'
        ).once

      subject
    end
  end

  describe '#find' do
    subject { described_class.find(name: 'db') }

    context 'when the database exists' do
      let(:database) do
        instance_double(Database)
      end

      before do
        allow(Request).to receive(:get)
          .with('/databases/db')
          .and_return(
            instance_double(
              Net::HTTPOK,
              code: '200',
              body: '{"data":{"id":"db","namespace":"staging","size":"10Gb",'\
                    '"type":"mongo","created_at":"2017-03-24T00:21:24Z",'\
                    '"updated_at":"2017-03-24T00:21:24Z"}}'
            )
          )

        allow(Database).to receive(:new)
          .with(
            'id' => 'db',
            'size' => '10Gb',
            'namespace' => 'staging',
            'type' => 'mongo',
            'created_at' => '2017-03-24T00:21:24Z',
            'updated_at' => '2017-03-24T00:21:24Z'
          )
          .and_return(database)
      end

      it 'returns the database' do
        expect(subject).to eq(database)
      end
    end

    context 'when the database can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/databases/db')
          .and_return(
            instance_double(Net::HTTPNotFound, code: '404')
          )
      end

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#create' do
    subject { described_class.create(params) }

    let(:params) do
      {
        id: 'db',
        type: 'mongo',
        namespace: 'staging'
      }
    end

    before do
      allow(Request).to receive(:post)
        .with('/databases/', params)
        .and_return(
          instance_double(Net::HTTPOK, code: '201')
        )
    end

    it 'sends a post with the database\'s params' do
      expect(Request).to receive(:post)
        .with('/databases/', params)
        .once

      subject
    end

    it 'checks if the status of the response is 201' do
      expect(subject).to eq(true)
    end

    context 'when the reponse status is 422' do
      before do
        allow(Request).to receive(:post)
          .with('/databases/', params)
          .and_return(
            instance_double(Net::HTTPOK, code: '422')
          )
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#destroy' do
    subject { described_class.destroy(database: database) }

    let(:database) { instance_double(Database, id: 'mydb') }

    it 'sends a delete request with the db id' do
      expect(Request).to receive(:delete).with('/databases/mydb').once

      subject
    end
  end
end
