# require 'rails_helper'

# RSpec.describe "resource_verifications#update", type: :request do
#   subject(:make_request) do
#     jsonapi_put "//resource_verifications/#{verification.id}", payload
#   end

#   describe 'basic update' do
#     let!(:verification) { create(:verification) }

#     let(:payload) do
#       {
#         data: {
#           id: verification.id.to_s,
#           type: 'resource_verifications',
#           attributes: {
#             # ... your attrs here
#           }
#         }
#       }
#     end

#     # Replace 'xit' with 'it' after adding attributes
#     xit 'updates the resource' do
#       expect(ResourceVerificationResource).to receive(:find).and_call_original
#       expect {
#         make_request
#         expect(response.status).to eq(200), response.body
#       }.to change { verification.reload.attributes }
#     end
#   end
# end
