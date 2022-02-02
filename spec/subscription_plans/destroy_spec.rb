require 'rails_helper'

RSpec.describe "subscription_plans#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/subscription-plans/#{subscription_plan.id}"
  end

  describe 'basic destroy' do
    let!(:subscription_plan) { create(:subscription_plan) }

    xit 'updates the resource' do
      expect(SubscriptionPlanResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { SubscriptionPlan.count }.by(-1)
      expect { subscription_plan.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
