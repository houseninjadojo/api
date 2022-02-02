require 'rails_helper'

RSpec.describe "subscription_plans#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/subscription-plans/#{subscription_plan.id}", params: params
  end

  describe 'basic fetch' do
    let!(:subscription_plan) { create(:subscription_plan) }

    it 'works' do
      expect(SubscriptionPlanResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('subscription-plans')
      expect(d.id).to eq(subscription_plan.id)
    end
  end
end
