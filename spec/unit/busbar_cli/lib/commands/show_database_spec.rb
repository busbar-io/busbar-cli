require 'spec_helper'

RSpec.describe Commands::ShowDatabase do
  describe '#show_db' do
    class DummyClass < Thor
      include Commands::ShowDatabase
    end

    let(:my_cli) { DummyClass.new }

    subject { my_cli.show_db('mydb') }

    before do
      allow(Printer).to receive(:print_resource)

      allow(DatabasesRepository).to receive(:find).with(name: 'mydb').and_return(database)

      allow(Services::Kube).to receive(:configure_temporary_profile)

      my_cli.options = double(:options, profile: 'some.profile')
    end

    let(:database) { instance_double(Database) }

    it 'prints the requested database' do
      expect(Printer).to receive(:print_resource).with(database).once

      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
