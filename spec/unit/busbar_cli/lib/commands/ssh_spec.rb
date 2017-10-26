require 'spec_helper'

RSpec.describe Commands::Ssh do
  describe '#ssh' do
    class DummyClass < Thor
      include Commands::Ssh
    end

    subject { my_cli.ssh('container', 'environment_name') }

    let(:my_cli) { DummyClass.new }

    before do
      allow(Services::Kube).to receive(:setup)

      allow(Services::Kube).to receive(:current_profile).and_return('current.profile')

      allow(Services::Kube).to receive(:configure_temporary_profile)

      allow(Kernel).to receive(:exec)

      allow(my_cli).to receive(:`).with('tput lines').and_return("44\n")

      allow(my_cli).to receive(:`).with('tput cols').and_return("180\n")

      my_cli.options = double(:options, profile: 'some.profile')
    end

    it 'opens a terminal session to the container' do
      expect(Kernel).to receive(:exec)
        .with(
          "#{KUBECTL} --context=current.profile exec container -n  " \
          'environment_name -i -t -- ' \
          "/usr/bin/env LINES=44 COLUMNS=180 TERM=#{ENV['TERM']} /bin/bash -l"
        )
      subject
    end

    it 'uses the profile from the options' do
      expect(Services::Kube).to receive(:configure_temporary_profile).with('some.profile').once

      subject
    end
  end
end
