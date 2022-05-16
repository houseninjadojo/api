require 'rails_helper'

RSpec.describe "payments#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/payments", payload
  end

  describe 'basic create' do
    let(:user) { create(:user) }
    let(:invoice) { create(:invoice, user: user) }
    let(:params) do
      attributes_for(:payment)
    end
    let(:payload) do
      {
        data: {
          type: 'payments',
          attributes: params,
          relationships: {
            invoice: {
              data: {
                type: 'invoices',
                id: invoice.id.to_s,
              }
            }
          }
        }
      }
    end

    before {
      # headers = { "ACCEPT" => "application/json" }
      # post "/widgets", :params => { :widget => {:name => "My Widget"} }, :headers => headers
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'works' do
      expect(PaymentResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Payment.count }.by(1)
    end
  end
end
