require 'rails_helper'

RSpec.describe "subscriptions#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/subscriptions/#{subscription.id}"
  end

  describe 'basic destroy' do
    let!(:subscription) { create(:subscription) }

    xit 'updates the resource' do
      expect(SubscriptionResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Subscription.count }.by(-1)
      expect { subscription.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
