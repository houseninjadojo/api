require 'rails_helper'

RSpec.describe "payment_methods#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payment-methods", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:payment_method1) { create(:credit_card, user: user) }
    let!(:payment_method2) { create(:credit_card, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    xit 'works' do
      expect(PaymentMethodResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['payment_methods'])
      expect(d.map(&:id)).to match_array([payment_method1.id, payment_method2.id])
    end
  end
end
