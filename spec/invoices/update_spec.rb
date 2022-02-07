require 'rails_helper'

RSpec.describe "invoices#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/invoices/#{invoice.id}", payload
  end

  describe 'basic update' do
    let!(:invoice) { create(:invoice) }

    let(:payload) do
      {
        data: {
          id: invoice.id.to_s,
          type: 'invoices',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(InvoiceResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { invoice.reload.attributes }
    end
  end
end
