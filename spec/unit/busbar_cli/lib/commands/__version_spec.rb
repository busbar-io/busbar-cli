require 'spec_helper'

RSpec.describe Commands::Version do
  describe '#version' do
    class DummyClass < Thor
      include Commands::BusbarVersion
    end

    let(:my_cli) { DummyClass.new }

    before do
      allow(my_cli).to receive(:puts)
    end

    subject { my_cli.__version }

    it 'returns the current CLI version' do
      begin
        subject
      rescue SystemExit
        expect(my_cli).to have_received(:puts)
          .with("The current CLI version running is: #{BUSBAR_VERSION}")
      end
    end
  end
end
