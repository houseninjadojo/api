require 'rails_helper'

RSpec.describe "properties#create", type: :request do
  subject(:make_request) do
    jsonapi_post "//properties", payload
  end

  describe 'basic create' do
    let(:params) do
      attributes_for(:property)
    end
    let(:payload) do
      {
        data: {
          type: 'properties',
          attributes: params
        }
      }
    end

    it 'works' do
      expect(PropertyResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { Property.count }.by(1)
    end
  end
end
