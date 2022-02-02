require 'rails_helper'

RSpec.describe CommonRequestResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'common_requests',
          attributes: attributes_for(:common_request)
        }
      }
    end

    let(:instance) do
      CommonRequestResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { CommonRequest.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:common_request) { create(:common_request) }

    let(:payload) do
      {
        data: {
          id: common_request.id.to_s,
          type: 'common_requests',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      CommonRequestResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { common_request.reload.updated_at }
      # .and change { common_request.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:common_request) { create(:common_request) }

    let(:instance) do
      CommonRequestResource.find(id: common_request.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { CommonRequest.count }.by(-1)
    end
  end
end
