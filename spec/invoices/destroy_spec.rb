require 'rails_helper'

RSpec.describe "invoices#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/invoices/#{invoice.id}"
  end

  describe 'basic destroy' do
    let!(:invoice) { create(:invoice) }

    xit 'updates the resource' do
      expect(InvoiceResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Invoice.count }.by(-1)
      expect { invoice.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
