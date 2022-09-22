require 'rails_helper'

RSpec.describe "estimates#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/estimates", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user) }
    let!(:work_order) { create(:work_order, property: property) }
    let!(:estimate1) { create(:estimate, work_order: work_order) }
    let!(:estimate2) { create(:estimate, work_order: work_order) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(EstimateResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['estimates'])
      expect(d.map(&:id)).to match_array([estimate1.id, estimate2.id])
    end
  end
end
