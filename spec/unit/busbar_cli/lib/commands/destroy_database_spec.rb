require 'spec_helper'

RSpec.describe Commands::DestroyDatabase do
  describe '#destroy' do
    class DummyClass < Thor
      include Commands::DestroyDatabase
    end

    let(:my_cli) { DummyClass.new }

    subject { my_cli.destroy_db('mydb') }

    before do
      my_cli.options = double(:options, profile: 'some.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(DatabasesRepository).to receive(:find).with(name: 'mydb').and_return(database)

      allow(Services::DatabaseDestroyer).to receive(:call).with(database)
    end

    let(:database) { instance_double(Database) }

    it 'destroys the database' do
      expect(Services::DatabaseDestroyer).to receive(:call).with(database).once

      subject
    end

    context 'when the database can not be found' do
      let(:database) { nil }

      before do
        allow(my_cli).to receive(:puts)
      end

      it 'prints a message about it' do
        expect(my_cli).to receive(:puts).with('Database mydb not found')

        subject
      end

      it 'does not destroy anything' do
        expect(Services::DatabaseDestroyer).to_not receive(:call)

        subject
      end
    end
  end
end
