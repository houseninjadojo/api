require 'rails_helper'

RSpec.describe "properties#destroy", type: :request do
  subject(:make_request) do
    jsonapi_delete "//properties/#{property.id}"
  end

  describe 'basic destroy' do
    let!(:property) { create(:property) }

    it 'updates the resource' do
      expect(PropertyResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { Property.count }.by(-1)
      expect { property.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(json).to eq('meta' => {})
    end
  end
end
