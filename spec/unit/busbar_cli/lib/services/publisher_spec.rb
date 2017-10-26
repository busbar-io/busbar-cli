require 'spec_helper'

RSpec.describe Services::Publisher do
  describe '#call' do
    subject { described_class.call(environment) }

    let(:environment) { instance_double(Environment) }

    let(:published) { true }

    before do
      allow(EnvironmentsRepository).to receive(:publish)
        .with(environment: environment)
        .and_return(published)
    end

    it 'prints the result of the environment publishing' do
      expect(Printer).to receive(:print_result)
        .with(
          result: published,
          success_message: 'Environment scheduled for publishing',
          failure_message: 'Error while publishing the environment. ' \
                           'Please check its existence (and of its app)'
        ).once

      subject
    end
  end
end
