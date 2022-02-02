require 'rails_helper'

RSpec.describe "subscription_plans#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/subscription-plans", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:subscription_plan)
    end
    let(:payload) do
      {
        data: {
          type: 'subscription-plans',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(SubscriptionPlanResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { SubscriptionPlan.count }.by(1)
    end
  end
end
