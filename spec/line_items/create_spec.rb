require 'rails_helper'

RSpec.describe "line_items#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/line-items", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:line_item)
    end
    let(:payload) do
      {
        data: {
          type: 'line_items',
          attributes: params
        }
      }
    end

    xit 'works' do
      expect(LineItemResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { LineItem.count }.by(1)
    end
  end
end
