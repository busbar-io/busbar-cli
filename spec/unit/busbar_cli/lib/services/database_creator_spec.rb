require 'spec_helper'

RSpec.describe Services::DatabaseCreator do
  describe '#call' do
    subject do
      described_class.call('db', 'mongo', 'staging')
    end

    before do
      allow(DatabasesRepository).to receive(:create).and_return(true)
      allow(described_class).to receive(:puts)
    end

    it 'creates a database with the given params' do
      expect(DatabasesRepository).to receive(:create)
        .with(
          id: 'db',
          type: 'mongo',
          namespace: 'staging'
        ).once

      subject
    end

    it 'prints a message about the database creation' do
      expect(described_class).to receive(:puts)
        .with('Creating database db mongo on environment staging')
        .once

      subject
    end

    it 'prints a message once the database creation was scheduled' do
      expect(described_class).to receive(:puts)
        .with('Database scheduled for creation')
        .once

      subject
    end

    context 'when the DB creation fails' do
      before do
        allow(DatabasesRepository).to receive(:create).and_return(false)
      end

      it 'warns the user about the creation fail' do
        expect(described_class).to receive(:puts)
          .with('There was an issue with the creation of the DB db mongo' \
                "Make sure that:\n" \
                "- DB name must be unique\n" \
                "- DB name must not contain uppercase characters, dots(.) or underscores(_)\n" \
                '- DB type must be supported')
          .once

        subject
      end
    end
  end
end
