# require 'rails_helper'

# RSpec.describe ResourceVerificationResource, type: :resource do
#   describe 'serialization' do
#     let!(:verification) { create(:verification) }

#     xit 'works' do
#       render
#       data = jsonapi_data[0]
#       expect(data.id).to eq(verification.id)
#       expect(data.jsonapi_type).to eq('resource_verifications')
#     end
#   end

#   describe 'filtering' do
#     let!(:verification1) { create(:verification) }
#     let!(:verification2) { create(:verification) }

#     context 'by id' do
#       before do
#         params[:filter] = { id: { eq: verification2.id } }
#       end

#       xit 'works' do
#         render
#         expect(d.map(&:id)).to eq([verification2.id])
#       end
#     end
#   end

#   describe 'sorting' do
#     describe 'by id' do
#       let!(:verification1) { create(:verification) }
#       let!(:verification2) { create(:verification) }

#       context 'when ascending' do
#         before do
#           params[:sort] = 'id'
#         end

#         xit 'works' do
#           render
#           expect(d.map(&:id)).to eq([
#             verification1.id,
#             verification2.id
#           ])
#         end
#       end

#       context 'when descending' do
#         before do
#           params[:sort] = '-id'
#         end

#         xit 'works' do
#           render
#           expect(d.map(&:id)).to eq([
#             verification2.id,
#             verification1.id
#           ])
#         end
#       end
#     end
#   end

#   describe 'sideloading' do
#     # ... your tests ...
#   end
# end
