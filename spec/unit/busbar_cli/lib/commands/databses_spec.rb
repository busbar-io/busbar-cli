require 'spec_helper'

RSpec.describe Commands::Databases do
  describe '#databases' do
    class DummyClass < Thor
      include Commands::Databases
    end

    subject { my_cli.databases }

    let(:my_cli) { DummyClass.new }

    before do
      allow(DatabasesRepository).to receive(:all).and_return(databases)

      allow(my_cli).to receive(:puts)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    let(:databases) do
      [db_1, db_2, db_3]
    end

    let(:db_1) { instance_double(Database, id: 'db1', type: 'mongo', namespace: 'staging') }
    let(:db_2) { instance_double(Database, id: 'db2', type: 'mongo', namespace: 'production') }
    let(:db_3) { instance_double(Database, id: 'db3', type: 'redis', namespace: 'staging') }

    it 'prints all the databases' do
      expect(my_cli).to receive(:puts)
        .with('db1 (mongo) - staging')
      expect(my_cli).to receive(:puts)
        .with('db2 (mongo) - production')
      expect(my_cli).to receive(:puts)
        .with('db3 (redis) - staging')

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
