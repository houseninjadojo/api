require 'rails_helper'

RSpec.describe "estimates#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/estimates/#{estimate.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user) }
    let!(:work_order) { create(:work_order, property: property) }
    let!(:estimate) { create(:estimate, work_order: work_order) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(EstimateResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('estimates')
      expect(d.id).to eq(estimate.id)
    end
  end
end
