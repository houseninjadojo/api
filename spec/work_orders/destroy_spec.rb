require 'rails_helper'

RSpec.describe "work_orders#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/work-orders/#{work_order.id}"
  end

  describe 'basic destroy' do
    let!(:work_order) { create(:work_order) }

    xit 'updates the resource' do
      expect(WorkOrderResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { WorkOrder.count }.by(-1)
      expect { work_order.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
