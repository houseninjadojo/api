require 'rails_helper'

RSpec.describe "line_items#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/line-items/#{line_item.id}", payload
  end

  describe 'basic update' do
    let!(:line_item) { create(:line_item) }

    let(:payload) do
      {
        data: {
          id: line_item.id.to_s,
          type: 'line_items',
          attributes: {
            # ... your attrs here
          }
        }
      }
    end

    # Replace 'xit' with 'it' after adding attributes
    xit 'updates the resource' do
      expect(LineItemResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { line_item.reload.attributes }
    end
  end
end
