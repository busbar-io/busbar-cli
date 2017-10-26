require 'spec_helper'

RSpec.describe Services::Environments do
  describe '#call' do
    subject { described_class.call('app_id') }

    before do
      allow(EnvironmentsRepository).to receive(:by_app)
        .with(app_id: 'app_id')
        .and_return(environments)

      allow(described_class).to receive(:puts)
    end

    let(:environment_1) do
      instance_double(
        Environment,
        id: 'some_environment_id_1',
        name: 'staging',
        buildpack_id: 'ruby'
      )
    end

    let(:environment_2) do
      instance_double(
        Environment,
        id: 'some_environment_id_2',
        name: 'staging',
        buildpack_id: 'ruby'
      )
    end

    let(:environment_3) do
      instance_double(
        Environment,
        id: 'some_environment_id_3',
        name: 'staging',
        buildpack_id: 'ruby'
      )
    end

    let(:environments) do
      [environment_1, environment_2, environment_3]
    end

    it 'prints the header' do
      expect(described_class).to receive(:puts)
        .with('ID - NAME - BUILDPACK')

      subject
    end

    it 'prints all the environments' do
      expect(described_class).to receive(:puts)
        .with('some_environment_id_1 - staging - ruby')
      expect(described_class).to receive(:puts)
        .with('some_environment_id_2 - staging - ruby')
      expect(described_class).to receive(:puts)
        .with('some_environment_id_3 - staging - ruby')

      subject
    end
  end
end
