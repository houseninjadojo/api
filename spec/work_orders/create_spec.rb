require 'rails_helper'

RSpec.describe "work_orders#create", type: :request do
  subject(:make_request) do
    jsonapi_post "/work-orders", payload
  end

  describe 'basic create' do
    let(:property) { create(:property) }
    let(:params) do
      attributes_for(:work_order)
    end
    let(:payload) do
      {
        data: {
          type: 'work-orders',
          attributes: params,
          relationships: {
            property: {
              data: {
                type: 'properties',
                id: property.id
              }
            }
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(create(:user))
    }

    it 'works' do
      expect(WorkOrderResource).to receive(:build).and_call_original
      expect {
        make_request
        expect(response.status).to eq(201), response.body
      }.to change { WorkOrder.count }.by(1)
    end
  end
end
