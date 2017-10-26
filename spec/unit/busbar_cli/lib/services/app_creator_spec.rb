require 'spec_helper'

RSpec.describe Services::AppCreator do
  describe '#call' do
    subject do
      described_class.call(
        id: 'app_id',
        buildpack_id: 'ruby',
        repository: 'git@repo.example',
        default_branch: 'master',
        default_env: 'staging',
        environment: 'environment_attributes'
      )
    end

    before do
      allow(AppsRepository).to receive(:create)
      allow_any_instance_of(described_class).to receive(:puts)
    end

    it 'creates an app with the given params' do
      expect(AppsRepository).to receive(:create)
        .with(
          id: 'app_id',
          buildpack_id: 'ruby',
          repository: 'git@repo.example',
          default_branch: 'master',
          default_env: 'staging',
          environment: 'environment_attributes'
        ).once

      subject
    end

    it 'prints a message about the app creation' do
      expect_any_instance_of(described_class).to receive(:puts)
        .with('Creating app_id, please stand by...')
        .once

      subject
    end

    context 'when the given repository is nil' do
      subject do
        described_class.call(
          id: 'app_id',
          buildpack_id: 'ruby',
          repository: nil,
          default_branch: 'master',
          default_env: 'staging',
          environment: 'environment_attributes'
        )
      end

      before do
        allow_any_instance_of(described_class).to receive(:`)
          .with('git remote get-url origin')
          .and_return("git@autodetected_repository\n")
      end

      it 'autodetects the repository' do
        expect(AppsRepository).to receive(:create)
          .with(
            id: 'app_id',
            buildpack_id: 'ruby',
            repository: 'git@autodetected_repository',
            default_branch: 'master',
            default_env: 'staging',
            environment: 'environment_attributes'
          ).once

        subject
      end

      it 'prints a message about the app creation' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('Creating app_id, please stand by...')
          .once

        subject
      end
    end

    context 'when the given default_env is nil' do
      subject do
        described_class.call(
          id: 'app_id',
          buildpack_id: 'ruby',
          repository: 'git@repo.example',
          default_branch: 'master',
          default_env: nil,
          environment: 'environment_attributes'
        )
      end

      it 'creates an app with the given params and no default_env param' do
        expect(AppsRepository).to receive(:create)
          .with(
            id: 'app_id',
            buildpack_id: 'ruby',
            repository: 'git@repo.example',
            default_branch: 'master',
            environment: 'environment_attributes'
          ).once

        subject
      end

      it 'prints a message about the app creation' do
        expect_any_instance_of(described_class).to receive(:puts)
          .with('Creating app_id, please stand by...')
          .once

        subject
      end
    end

    context 'when the app id is invalid' do
      subject do
        described_class.call(
          id: 'an_app_id_with_more_than_17_characters',
          buildpack_id: 'ruby',
          repository: nil,
          default_branch: 'master',
          default_env: 'staging',
          environment: 'environment_attributes'
        )
      end

      it 'autodetects the repository' do
        allow_any_instance_of(described_class).to receive(:exit)

        expect_any_instance_of(described_class).to receive(:puts)
          .with('The application name has to be shorter than 18 characters')
          .once

        subject
      end

      it 'exits with code 1' do
        expect(-> { subject }).to exit_with_code(1)
      end
    end
  end
end
