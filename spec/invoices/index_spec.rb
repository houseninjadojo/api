require 'rails_helper'

RSpec.describe "invoices#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/invoices", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:invoice1) { create(:invoice, user: user) }
    let!(:invoice2) { create(:invoice, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(InvoiceResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['invoices'])
      expect(d.map(&:id)).to match_array([invoice1.id, invoice2.id])
    end
  end
end
