require 'spec_helper'

RSpec.describe Services::LatestBuildLogs do
  describe '#call' do
    subject { described_class.call(environment) }

    let(:environment) { instance_double(Environment, name: 'staging', app_id: 'app_id') }
    let(:build) { instance_double(Build, log: 'this is a log') }

    before do
      allow(BuildsRepository).to receive(:latest).with(environment).and_return(build)

      allow(described_class).to receive(:print)

      allow(described_class).to receive(:sleep)

      allow(described_class).to receive(:system).with('clear')
    end

    context 'when the build finishes with success' do
      before do
        allow(build).to receive(:state).and_return('building', 'building', 'ready')
      end

      it 'keeps fetching the latest build logs until the build is ready' do
        expect(BuildsRepository).to receive(:latest).with(environment).thrice

        subject
      end

      it 'clears the terminal output until build is ready' do
        expect(described_class).to receive(:system).with('clear').thrice

        subject
      end

      it 'prints latest build logs until the build is ready' do
        expect(described_class).to receive(:print).with('this is a log').thrice

        subject
      end

      it 'sleeps after each loop until the build is ready' do
        expect(described_class).to receive(:sleep).with(3).twice

        subject
      end
    end

    context 'when the build breaks' do
      before do
        allow(build).to receive(:state).and_return('building', 'building', 'broken')
      end

      it 'keeps fetching the latest build logs until the build is broken' do
        expect(BuildsRepository).to receive(:latest).with(environment).thrice

        subject
      end

      it 'clears the terminal output until build is broken' do
        expect(described_class).to receive(:system).with('clear').thrice

        subject
      end

      it 'prints latest build logs until the build is broken' do
        expect(described_class).to receive(:print).with('this is a log').thrice

        subject
      end

      it 'sleeps after each loop until the build is broken' do
        expect(described_class).to receive(:sleep).with(3).twice

        subject
      end
    end
  end
end
