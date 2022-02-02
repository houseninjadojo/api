require 'rails_helper'

RSpec.describe "credit_cards#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/payment-methods/#{credit_card.id}"
  end

  describe 'basic destroy' do
    let!(:credit_card) { create(:credit_card) }

    xit 'updates the resource' do
      expect(CreditCardResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { CreditCard.count }.by(-1)
      expect { credit_card.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
