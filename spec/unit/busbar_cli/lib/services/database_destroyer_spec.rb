require 'spec_helper'

RSpec.describe Services::DatabaseDestroyer do
  describe '#call' do
    subject { described_class.call(database) }

    let(:database) { instance_double(Database, id: 'mydb') }

    before do
      allow_any_instance_of(described_class).to receive(:puts)
      allow(DatabasesRepository).to receive(:destroy)
      allow(Confirmator).to receive(:confirm)
      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')
    end

    it 'asks for confirmation' do
      expect(Confirmator).to receive(:confirm)
        .with(
          question: 'Are you sure you want to destroy the database mydb ' \
                    'on profile current.profile? ' \
                    'This action is irreversible.'
        ).once
      subject
    end

    it 'destroys the database' do
      expect(DatabasesRepository).to receive(:destroy).with(database: database).once

      subject
    end

    it 'prints a message about the database destruction' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('Database mydb is scheduled for destruction')
        .once

      subject
    end
  end
end
