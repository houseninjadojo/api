require 'rails_helper'

RSpec.describe Arrivy::Webhook::IngestJob, type: :job do
  describe "#perform_*" do
    let(:payload) {
      {
        # @todo
      }
    }
    let(:webhook_event) { create(:webhook_event, service: 'arrivy') }

    xit "creates Arrivy::Event" do
      expect(ArrivyEvent).to receive(:new).with(payload)
      job.perform_now(webhook_event)
    end
  end
end
