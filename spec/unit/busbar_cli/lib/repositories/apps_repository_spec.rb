require 'spec_helper'

RSpec.describe AppsRepository do
  describe '#all' do
    subject { described_class.all }

    before do
      allow(Request).to receive(:get)
        .with('/apps/')
        .and_return(
          instance_double(
            Net::HTTPOK,
            body: '{"data":[{"id":"some_app","default_branch":"master","buildpack_id":"ruby",'\
                  '"repository":"git@github.com/some_app.git",'\
                  '"environments":["production","test"],"created_at":"2017-03-24T00:21:24Z",'\
                  '"updated_at":"2017-03-24T00:21:24Z"}]}'
          )
        )
    end

    it 'creates a new app of each app fetched' do
      expect(App).to receive(:new)
        .with(
          'id' => 'some_app',
          'default_branch' => 'master',
          'buildpack_id' => 'ruby',
          'repository' => 'git@github.com/some_app.git',
          'environments' => %w(production test),
          'created_at' => '2017-03-24T00:21:24Z',
          'updated_at' => '2017-03-24T00:21:24Z'
        ).once

      subject
    end
  end

  describe '#find' do
    subject { described_class.find(app_id: 'some_app') }

    context 'when the app exists' do
      let(:app) do
        instance_double(App)
      end

      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app')
          .and_return(
            instance_double(
              Net::HTTPOK,
              code: '200',
              body: '{"data":{"id":"some_app","default_branch":"master","buildpack_id":"ruby",'\
                    '"repository":"git@github.com/some_app.git",'\
                    '"environments":["production","test"],"created_at":"2017-03-24T00:21:24Z",'\
                    '"updated_at":"2017-03-24T00:21:24Z"}}'
            )
          )

        allow(App).to receive(:new)
          .with(
            'id' => 'some_app',
            'default_branch' => 'master',
            'buildpack_id' => 'ruby',
            'repository' => 'git@github.com/some_app.git',
            'environments' => %w(production test),
            'created_at' => '2017-03-24T00:21:24Z',
            'updated_at' => '2017-03-24T00:21:24Z'
          )
          .and_return(app)
      end

      it 'returns the app' do
        expect(subject).to eq(app)
      end
    end

    context 'when the app can\'t be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app')
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
        id: 'some_app',
        branch: 'master',
        buildpack_id: 'ruby',
        repository: 'git@github.com/some_app.git'
      }
    end

    it 'sends a post with the app\'s params' do
      expect(Request).to receive(:post)
        .with('/apps/', params)
        .once

      subject
    end
  end

  describe '#destroy' do
    subject { described_class.destroy(app: app) }

    let(:app) do
      instance_double(App, id: 'some_app')
    end

    it 'sends a delete request with the app id' do
      expect(Request).to receive(:delete)
        .with('/apps/some_app')
        .once

      subject
    end
  end
end
