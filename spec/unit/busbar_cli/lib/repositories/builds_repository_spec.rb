require 'spec_helper'

RSpec.describe BuildsRepository do
  describe '#latest' do
    subject { described_class.latest(environment) }

    let(:environment) do
      instance_double(
        Environment,
        app_id: 'some_app',
        name: 'staging'
      )
    end

    before do
      allow(Request).to receive(:get)
        .with('/apps/some_app/environments/staging/builds/latest')
        .and_return(
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: '{"data":{"id":"58e2905c9de2310006bbf0bf","state":"ready",'\
                  '"buildpack_id":"ruby","app_id":"some_app",'\
                  '"repository":"git@github.com:PaeDae/da-vinci.git","branch":"master",'\
                  '"commit":"58e28ec2ebd1073200eb24d93e5b7d97eca1a880","tag":"0.15.0",'\
                  '"commands":{"web":"bundle exec puma -C config/puma.rb"},'\
                  '"built_at":"2017-04-03T18:12:41.740Z",'\
                  '"environment_id":"58d466844b8b950006d7d730","environment_name":"production",'\
                  '"created_at":"2017-04-03T18:11:40Z","updated_at":"2017-04-03T18:12:41Z",'\
                  '"log": "This is a build log"}}'
          )
        )
    end

    it 'returns the latest build of the given environment' do
      expect(subject).to have_attributes(
        app_id: 'some_app',
        environment_name: 'production',
        commit: '58e28ec2ebd1073200eb24d93e5b7d97eca1a880',
        branch: 'master',
        tag: '0.15.0',
        state: 'ready',
        updated_at: '2017-04-03T18:12:41Z',
        log: 'This is a build log'
      )
    end

    context 'when the environment or build can not be found' do
      before do
        allow(Request).to receive(:get)
          .with('/apps/some_app/environments/staging/builds/latest')
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
