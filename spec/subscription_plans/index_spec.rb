require 'rails_helper'

RSpec.describe "subscription_plans#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/subscription-plans", params: params
  end

  describe 'basic fetch' do
    let!(:subscription_plan1) { create(:subscription_plan) }
    let!(:subscription_plan2) { create(:subscription_plan) }

    it 'works' do
      expect(SubscriptionPlanResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['subscription-plans'])
      expect(d.map(&:id)).to match_array([subscription_plan1.id, subscription_plan2.id])
    end
  end
end
