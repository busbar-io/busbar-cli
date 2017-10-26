require 'spec_helper'

RSpec.describe Commands::CreateDatabase do
  describe '#create_database' do
    class DummyClass < Thor
      include Commands::CreateDatabase
    end

    let(:my_cli) { DummyClass.new }

    subject { my_cli.create_db('db', 'mongo', 'staging') }

    before do
      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(Services::DatabaseCreator).to receive(:call)

      my_cli.options = double(
        :options,
        repository: 'git@some_repo.git',
        buildpack_id: 'ruby',
        branch: 'develop',
        public: true,
        profile: 'some.profile'
      )
    end

    it 'creates the databsae' do
      expect(Services::DatabaseCreator).to receive(:call).with('db', 'mongo', 'staging').once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
