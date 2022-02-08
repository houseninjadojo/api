require 'rails_helper'

RSpec.describe "work_orders#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/work-orders/#{work_order.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user) }
    let!(:work_order) { create(:work_order, property: property) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(WorkOrderResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('work-orders')
      expect(d.id).to eq(work_order.id)
    end
  end
end
