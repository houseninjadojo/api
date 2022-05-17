require 'rails_helper'

RSpec.describe Hubspot::Deal::UpdateStatusJob, type: :job do
  describe "#perform_*" do
    let(:work_order) { create(:work_order, hubspot_id: '12345') }
    let(:job) { Hubspot::Deal::UpdateStatusJob }
    let(:params) {
      { dealstage: work_order.status.name }
    }

    it "calls Hubspot::Deal.update!" do
      expect(Hubspot::Deal).to receive(:update!).with(work_order.hubspot_id, params).and_return(true)
      job.perform_now(work_order)
    end
  end
end
