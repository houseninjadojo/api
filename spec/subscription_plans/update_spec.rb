require 'rails_helper'

RSpec.describe "subscription_plans#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/subscription-plans/#{subscription_plan.id}", payload
  end

  describe 'basic update' do
    let!(:subscription_plan) { create(:subscription_plan) }

    let(:payload) do
      {
        data: {
          id: subscription_plan.id.to_s,
          type: 'subscription_plans',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(SubscriptionPlanResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { subscription_plan.reload.attributes }
    end
  end
end
