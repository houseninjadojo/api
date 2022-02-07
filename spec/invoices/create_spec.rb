require 'rails_helper'

RSpec.describe "invoices#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/invoices", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:invoice)
    end
    let(:payload) do
      {
        data: {
          type: 'invoices',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(InvoiceResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Invoice.count }.by(1)
    end
  end
end
