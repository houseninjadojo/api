require 'rails_helper'

RSpec.describe "subscriptions#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/subscriptions/#{subscription.id}"
  end

  describe 'basic destroy' do
    let(:user) { create(:user) }
    let!(:subscription) { create(:subscription, user: user) }

    before { allow_any_instance_of(Auth).to receive(:current_user).and_return(user) }

    it 'updates the resource' do
      expect(SubscriptionResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to have_enqueued_job(Sync::Subscription::Stripe::Outbound::DeleteJob)
      # expect { subscription.reload }
      #   .to change { subscription.canceled_at }
      expect(json).to eq('meta' => {})
    end
  end
end
