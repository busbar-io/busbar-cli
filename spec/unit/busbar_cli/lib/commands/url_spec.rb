require 'spec_helper'

RSpec.describe Commands::Url do
  describe '#url' do
    class DummyClass < Thor
      include Commands::Url
    end

    subject { my_cli.url('app_id', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    let(:environment) { instance_double(Environment, public: true) }

    let(:option_internal) { false }
    let(:option_ingress) { false }
    let(:option_public) { false }

    before do
      my_cli.options = double(
        :options,
        public: option_public,
        ingress: option_ingress,
        internal: option_internal,
        profile: 'some.profile'
      )

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(my_cli).to receive(:puts)

      allow(EnvironmentsRepository).to receive(:find)
        .with(app_id: 'app_id', environment_name: 'environment_name')
        .and_return(environment)

      allow(Services::Url).to receive(:internal).with(environment).and_return('internal.url')

      allow(Services::Url).to receive(:ingress).with(environment).and_return('ingress.url')

      allow(Services::Url).to receive(:public).with(environment).and_return('public.url')
    end

    context 'when the option is set to internal' do
      let(:option_internal) { true }

      it 'prints the internal url' do
        expect(my_cli).to receive(:puts).with('internal.url').once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'when the option is set to ingress' do
      let(:option_ingress) { true }

      it 'prints the ingress url' do
        expect(my_cli).to receive(:puts).with('ingress.url').once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'when the option is set to public' do
      let(:option_public) { true }

      it 'prints the public url' do
        expect(my_cli).to receive(:puts).with('public.url').once

        subject
      end

      it 'uses the profile from the options' do
        expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

        subject
      end
    end

    context 'when no option is set' do
      context 'and the app is not public' do
        let(:environment) { instance_double(Environment, public: false) }

        it 'prints the ingress url' do
          expect(my_cli).to receive(:puts).with('ingress.url').once

          subject
        end

        it 'uses the profile from the options' do
          expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

          subject
        end
      end
    end
  end
end
