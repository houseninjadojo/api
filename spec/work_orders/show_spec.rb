require 'rails_helper'

RSpec.describe "work_orders#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/work-orders/#{work_order.id}", params: params
  end

  describe 'basic fetch' do
    let!(:work_order) { create(:work_order) }

    it 'works' do
      expect(WorkOrderResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('work-orders')
      expect(d.id).to eq(work_order.id)
    end
  end
end
