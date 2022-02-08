require 'rails_helper'

RSpec.describe "payments#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payments/#{payment.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:payment) { create(:payment, :with_relationships, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(PaymentResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('payments')
      expect(d.id).to eq(payment.id)
    end
  end
end
