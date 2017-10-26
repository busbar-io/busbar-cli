require 'spec_helper'

RSpec.describe Services::EnvironmentCreator do
  describe '#call' do
    subject do
      described_class.call(
        app_id: 'app_id',
        name: 'environment_name',
        buildpack_id: 'ruby',
        public: true,
        default_branch: 'master',
        settings: 'settings'
      )
    end

    let(:environment) { instance_double(Environment) }

    before do
      allow(EnvironmentsRepository).to receive(:create)
        .with(
          app_id: 'app_id',
          name: 'environment_name',
          buildpack_id: 'ruby',
          public: true,
          default_branch: 'master',
          settings: 'settings'
        ).and_return(true)

      allow(EnvironmentsRepository).to receive(:find)
        .with(app_id: 'app_id', environment_name: 'environment_name')
        .and_return(environment)

      allow(described_class).to receive(:sleep)

      allow(environment).to receive(:state).and_return('pending', 'pending', 'available')
    end

    it 'create an environment' do
      expect(described_class).to receive(:call)
        .with(
          app_id: 'app_id',
          name: 'environment_name',
          buildpack_id: 'ruby',
          public: true,
          default_branch: 'master',
          settings: 'settings'
        )

      subject
    end

    it 'output creation message' do
      expect do
        subject
      end.to output("Creating environment environment_name on app app_id. This may take a while...\n").to_stdout
    end

    it 'wait for the environment creation' do
      expect_any_instance_of(described_class).to receive(:puts)
        .and_return('Creating environment environment_name on app app_id. This may take a while...')

      expect_any_instance_of(described_class).to receive(:sleep).with(1).twice

      subject
    end

    context 'when there was an issue with the environment creation' do
      before do
        allow(EnvironmentsRepository).to receive(:create).and_return(false)
      end

      it 'prints a message about the guidelines for environment names and exit 0' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with(
            "There was an issue on the creation of app_id environment_name.\n" \
            "Make sure that the new environment name:\n"\
            "- Is unique for its app. Ex: the same app can't have two staging environments\n" \
            '- Contains only letters, numbers, dots(.) or dashes(-)'
          ).once

        expect(-> { subject }).to exit_with_code(0)
      end
    end
  end
end
