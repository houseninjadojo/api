require 'rails_helper'

RSpec.describe "payments#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/payments", params: params
  end

  describe 'basic fetch' do
    let!(:payment1) { create(:payment, :with_relationships) }
    let!(:payment2) { create(:payment, :with_relationships) }

    it 'works' do
      expect(PaymentResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['payments'])
      expect(d.map(&:id)).to match_array([payment1.id, payment2.id])
    end
  end
end
