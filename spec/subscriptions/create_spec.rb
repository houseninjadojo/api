require 'rails_helper'

RSpec.describe "subscriptions#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/subscriptions", payload
  end

  describe 'basic create' do
    let(:user) { create(:user) }
    let(:credit_card) { create(:credit_card) }
    let(:subscription_plan) { create(:subscription_plan) }
    let(:params) do
      attributes_for(:subscription)
    end
    let(:payload) do
      {
        data: {
          type: 'subscriptions',
          attributes: {},
          relationships: {
            payment_method: {
              data: {
                type: 'credit-cards',
                id: credit_card.id,
              }
            },
            subscription_plan: {
              data: {
                type: 'subscription-plans',
                id: subscription_plan.id,
              }
            },
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            },
          },
        }
      }
    end

    it 'works' do
      expect(SubscriptionResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Subscription.count }.by(1)
    end
  end
end
