require 'spec_helper'

RSpec.describe EnvironmentsRepository do
  describe '#by_app' do
    subject { described_class.by_app(app_id: 'some_app') }

    before do
      allow(Request).to receive(:get)
        .with('/apps/some_app/environments/')
        .and_return(
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: '{"data":[{"id":"58d466844b8b950006d7d730","name":"staging",'\
                  '"state":"available","default_branch":"master","buildpack_id":"ruby",'\
                  '"namespace":"staging","public":true,"app_id":"some_app",'\
                  '"created_at":"2017-03-24T00:21:24Z","updated_at":"2017-03-24T00:21:24Z",'\
                  '"default_node_id":"1x.standard","settings":{"SOME_SETTING":"some_value"}}]}'
          )
        )
    end

    it 'creates a new environment of each app fetched' do
      expect(Environment).to receive(:new)
        .with(
          'id' => '58d466844b8b950006d7d730',
          'name' => 'staging',
          'state' => 'available',
          'default_branch' => 'master',
          'buildpack_id' => 'ruby',
          'namespace' => 'staging',
          'public' => true,
          'created_at' => '2017-03-24T00:21:24Z',
          'updated_at' => '2017-03-24T00:21:24Z',
          'default_node_id' => '1x.standard',
          'settings' => { 'SOME_SETTING' => 'some_value' },
          'app_id' => 'some_app'
        ).once

      subject
    end

    context 'when the app can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/')
          .and_return(
            instance_double(Net::HTTPNotFound, code: '404')
          )
      end

      it 'returns nil' do
        expect(subject).to eq([])
      end
    end
  end

  describe '#find' do
    subject { described_class.find(environment_name: 'staging', app_id: 'some_app') }

    context 'when environment exists' do
      let(:environment) do
        instance_double(Environment)
      end

      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging')
          .and_return(
            instance_double(
              Net::HTTPOK,
              code: '200',
              body: '{"data":{"id":"58d466844b8b950006d7d730","name":"staging",'\
                    '"state":"available","default_branch":"master","buildpack_id":"ruby",'\
                    '"namespace":"staging","public":true,"app_id":"some_app",'\
                    '"created_at":"2017-03-24T00:21:24Z","updated_at":"2017-03-24T00:21:24Z",'\
                    '"default_node_id":"1x.standard","settings":{"SOME_SETTING":"some_value"}}}'
            )
          )

        allow(Environment).to receive(:new)
          .with(
            'id' => '58d466844b8b950006d7d730',
            'name' => 'staging',
            'state' => 'available',
            'default_branch' => 'master',
            'buildpack_id' => 'ruby',
            'namespace' => 'staging',
            'public' => true,
            'created_at' => '2017-03-24T00:21:24Z',
            'updated_at' => '2017-03-24T00:21:24Z',
            'default_node_id' => '1x.standard',
            'settings' => { 'SOME_SETTING' => 'some_value' },
            'app_id' => 'some_app'
          )
          .and_return(environment)
      end

      it 'returns the environment' do
        expect(subject).to eq(environment)
      end
    end

    context 'when the app or environment can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging')
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
        app_id: 'some_app',
        name: 'staging',
        branch: 'master',
        buildpack_id: 'ruby'
      }
    end

    before do
      allow(Request).to receive(:post)
        .with('/apps/some_app/environments/', params)
        .and_return(
          instance_double(Net::HTTPOK, code: '201')
        )
    end

    it 'sends a post with the environment\'s params' do
      expect(Request).to receive(:post)
        .with('/apps/some_app/environments/', params)
        .once

      subject
    end

    it 'checks if the status of the response is 201' do
      expect(subject).to eq(true)
    end
  end

  describe '#destroy' do
    subject { described_class.destroy(environment: environment) }

    let(:environment) do
      instance_double(Environment, app_id: 'some_app', name: 'staging')
    end

    before do
      allow(Request).to receive(:delete)
        .with('/apps/some_app/environments/staging')
        .and_return(
          instance_double(Net::HTTPNotFound, code: '204')
        )
    end

    it 'sends a delete request for the environment url' do
      expect(Request).to receive(:delete)
        .with('/apps/some_app/environments/staging')
        .once

      subject
    end

    it 'checks if the status of the response is 204' do
      expect(subject).to eq(true)
    end
  end

  describe '#publish' do
    subject { described_class.publish(environment: environment) }

    let(:environment) do
      instance_double(Environment, app_id: 'some_app', name: 'staging')
    end

    before do
      allow(Request).to receive(:put).and_return(
        instance_double(Net::HTTPAccepted, code: '202')
      )
    end

    it 'sends a put request for the environment publish url' do
      expect(Request).to receive(:put)
        .with('/apps/some_app/environments/staging/publish', {})
        .once

      subject
    end

    it 'checks if the response status is 202' do
      expect(subject).to eq(true)
    end
  end

  describe '#resize' do
    subject { described_class.resize(environment: environment, node_type: '1x.standard') }

    let(:environment) do
      instance_double(Environment, app_id: 'some_app', name: 'staging')
    end

    before do
      allow(Request).to receive(:put).and_return(
        instance_double(Net::HTTPAccepted, code: '202')
      )
    end

    it 'sends a put request for the environment resize url' do
      expect(Request).to receive(:put)
        .with('/apps/some_app/environments/staging/resize', node_id: '1x.standard')
        .once

      subject
    end

    it 'checks if the response status is 202' do
      expect(subject).to eq(true)
    end
  end

  describe '#clone' do
    subject { described_class.clone(environment: environment, clone_name: 'staging-clone') }

    let(:environment) do
      instance_double(Environment, app_id: 'some_app', name: 'staging')
    end

    before do
      allow(Request).to receive(:post).and_return(
        instance_double(Net::HTTPAccepted, code: '202')
      )
    end

    it 'sends a put request for the environment clone url' do
      expect(Request).to receive(:post)
        .with('/apps/some_app/environments/staging/clone', clone_name: 'staging-clone')
        .once

      subject
    end

    it 'checks if the response status is 202' do
      expect(subject).to eq(true)
    end
  end
end
