require 'rails_helper'

RSpec.describe "work_orders#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/work-orders/#{work_order.id}", payload
  end

  describe 'basic update' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user)}
    let!(:work_order) { create(:work_order, property: property) }

    let(:payload) do
      {
        data: {
          id: work_order.id.to_s,
          type: 'work-orders',
          attributes: {
           vendor: 'a b c',
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    # Replace 'xit' with 'it' after adding attributes
    it 'updates the resource' do
      expect(WorkOrderResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { work_order.reload.attributes }
    end
  end
end
