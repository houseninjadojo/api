# require 'rails_helper'

# RSpec.describe "resource_verifications#index", type: :request do
#   let(:params) { {} }

#   subject(:make_request) do
#     jsonapi_get "//resource_verifications", params: params
#   end

#   describe 'basic fetch' do
#     let!(:verification1) { create(:verification) }
#     let!(:verification2) { create(:verification) }

#     it 'works' do
#       expect(ResourceVerificationResource).to receive(:all).and_call_original
#       make_request
#       expect(response.status).to eq(200), response.body
#       expect(d.map(&:jsonapi_type).uniq).to match_array(['resource_verifications'])
#       expect(d.map(&:id)).to match_array([verification1.id, verification2.id])
#     end
#   end
# end
