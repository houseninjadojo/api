require 'rails_helper'

RSpec.describe "subscriptions#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/subscriptions/#{subscription.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:subscription) { create(:subscription, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(SubscriptionResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('subscriptions')
      expect(d.id).to eq(subscription.id)
    end
  end
end
