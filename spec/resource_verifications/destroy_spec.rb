# require 'rails_helper'

# RSpec.describe "resource_verifications#destroy", type: :request do
#   subject(:make_request) do
#     jsonapi_delete "//resource_verifications/#{verification.id}"
#   end

#   describe 'basic destroy' do
#     let!(:verification) { create(:verification) }

#     it 'updates the resource' do
#       expect(ResourceVerificationResource).to receive(:find).and_call_original
#       expect {
#         make_request
#         expect(response.status).to eq(200), response.body
#       }.to change { ResourceVerification.count }.by(-1)
#       expect { verification.reload }
#         .to raise_error(ActiveRecord::RecordNotFound)
#       expect(json).to eq('meta' => {})
#     end
#   end
# end
