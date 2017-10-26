require 'spec_helper'
require 'fakefs/safe'

RSpec.describe Helpers::BusbarConfig do
  describe '#ensure_dependencies' do
    include FakeFS::SpecHelpers
    subject { described_class.ensure_dependencies }

    before do
      allow(FileUtils).to receive(:mkdir_p)
    end

    it 'creates a config folder for busbar files' do
      FakeFS.with_fresh do
        expect(FileUtils).to receive(:mkdir_p).with(BUSBAR_LOCAL_FOLDER).once
        subject
      end
    end
  end
end
