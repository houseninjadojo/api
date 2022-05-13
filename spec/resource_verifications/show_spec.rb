# require 'rails_helper'

# RSpec.describe "resource_verifications#show", type: :request do
#   let(:params) { {} }

#   subject(:make_request) do
#     jsonapi_get "//resource_verifications/#{verification.id}", params: params
#   end

#   describe 'basic fetch' do
#     let!(:verification) { create(:verification) }

#     it 'works' do
#       expect(ResourceVerificationResource).to receive(:find).and_call_original
#       make_request
#       expect(response.status).to eq(200)
#       expect(d.jsonapi_type).to eq('resource_verifications')
#       expect(d.id).to eq(verification.id)
#     end
#   end
# end
