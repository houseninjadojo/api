require 'rails_helper'

RSpec.describe "work_orders#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/work-orders", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user) }
    let!(:work_order1) { create(:work_order, property: property) }
    let!(:work_order2) { create(:work_order, property: property) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(WorkOrderResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['work-orders'])
      expect(d.map(&:id)).to match_array([work_order1.id, work_order2.id])
    end
  end
end
