require 'rails_helper'

RSpec.describe "invoices#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/invoices/#{invoice.id}", params: params
  end

  describe 'basic fetch' do
    let!(:user) { create(:user) }
    let!(:invoice) { create(:invoice, user: user) }

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(InvoiceResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('invoices')
      expect(d.id).to eq(invoice.id)
    end
  end
end
