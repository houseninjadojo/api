require 'rails_helper'

RSpec.describe "work_orders#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/work-orders/#{work_order.id}", payload
  end

  describe 'basic update' do
    let!(:work_order) { create(:work_order) }

    let(:payload) do
      {
        data: {
          id: work_order.id.to_s,
          type: 'work-orders',
          attributes: {
           vendor: 'a b c',
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    it 'updates the resource' do
      expect(WorkOrderResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { work_order.reload.attributes }
    end
  end
end
