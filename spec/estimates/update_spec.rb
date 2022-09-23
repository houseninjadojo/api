require 'rails_helper'

RSpec.describe "estimates#update", type: :request do
  subject(:make_request) do
    jsonapi_put "/estimates/#{estimate.id}", payload
  end

  describe 'basic update' do
    let!(:user) { create(:user) }
    let!(:property) { create(:property, user: user) }
    let!(:work_order) { create(:work_order, property: property) }
    let!(:estimate) { create(:estimate, work_order: work_order) }

    let(:payload) do
      {
        data: {
          id: estimate.id.to_s,
          type: 'estimates',
          attributes: {
            approved_at: Time.now,
          }
        }
      }
    end

    before {
      allow_any_instance_of(Auth).to receive(:current_user).and_return(user)
    }

    it 'updates the resource' do
      expect(EstimateResource).to receive(:find).and_call_original
      expect {
        make_request
        expect(response.status).to eq(200), response.body
      }.to change { estimate.reload.attributes }
    end
  end
end
