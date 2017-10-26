require 'spec_helper'

RSpec.describe Services::EnvironmentCloner do
  describe '#call' do
    subject { described_class.call(environment, 'environment-clone') }

    let(:environment) do
      instance_double(
        Environment,
        app_id: 'some_app',
        name: 'staging'
      )
    end

    before do
      allow(EnvironmentsRepository).to receive(:clone)
        .with(environment: environment, clone_name: 'environment-clone')
        .and_return(true)

      allow_any_instance_of(described_class).to receive(:puts)
    end

    it 'clones the environment' do
      expect(EnvironmentsRepository).to receive(:clone)
        .with(environment: environment, clone_name: 'environment-clone')
        .once

      subject
    end

    it 'informs the user that the cloning will be performed' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('Cloning some_app staging to '\
             'some_app environment-clone, stand by...')
        .once

      subject
    end

    it 'informs the user that the cloning was scheduled' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('Cloning scheduled!')
        .once

      subject
    end

    context 'when the cloning fails' do
      before do
        allow(EnvironmentsRepository).to receive(:clone)
          .with(environment: environment, clone_name: 'environment-clone')
          .and_return(false)
      end

      it 'informs the user that the cloning may have failed' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('Some issue happened during the cloning schedule. This operations may ' \
                "have failed\nPlease check your inputs and Busbar's state")
          .once

        subject
      end
    end
  end
end
