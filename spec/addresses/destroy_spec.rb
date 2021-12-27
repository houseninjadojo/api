require 'rails_helper'

RSpec.describe "addresses#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "/addresses/#{address.id}"
  end

  describe 'basic destroy' do
    let!(:address) { create(:address) }

    it 'updates the resource' do
      expect(AddressResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Address.count }.by(-1)
      expect { address.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
