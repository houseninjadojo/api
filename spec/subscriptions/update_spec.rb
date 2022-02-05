require 'rails_helper'

RSpec.describe "subscriptions#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/subscriptions/#{subscription.id}", payload
  end

  describe 'basic update' do
    let!(:subscription) { create(:subscription) }

    let(:payload) do
      {
        data: {
          id: subscription.id.to_s,
          type: 'subscriptions',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(SubscriptionResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { subscription.reload.attributes }
    end
  end
end
