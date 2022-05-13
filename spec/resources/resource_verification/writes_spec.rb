require 'rails_helper'

RSpec.describe ResourceVerificationResource, type: :resource do
  describe 'creating valid' do
    let(:user) { create(:user) }
    let(:payload) do
      {
        data: {
          type: 'resource_verifications',
          attributes: {
            resource_name: 'users',
            record_id: user.id,
            attribute: 'email',
            value: user.email,
          }
        }
      }
    end

    let(:instance) do
      ResourceVerificationResource.build(payload)
    end

    it 'works' do
      expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
    end
  end

  describe 'creating invalid' do
    let(:user) { create(:user) }
    let(:payload) do
      {
        data: {
          type: 'resource_verifications',
          attributes: {
            resource_name: 'users',
            record_id: user.id,
            attribute: 'email',
            value: 'bad email',
          }
        }
      }
    end

    let(:instance) do
      ResourceVerificationResource.build(payload)
    end

    it 'works' do
      expect(instance.save).to eq(false), instance.errors.full_messages.to_sentence
    end
  end

  # describe 'updating' do
  #   let!(:verification) { create(:verification) }

  #   let(:payload) do
  #     {
  #       data: {
  #         id: verification.id.to_s,
  #         type: 'resource_verifications',
  #         attributes: { } # Todo!
  #       }
  #     }
  #   end

  #   let(:instance) do
  #     ResourceVerificationResource.find(payload)
  #   end

  #   xit 'works (add some attributes and enable this spec)' do
  #     expect {
  #       expect(instance.update_attributes).to eq(true)
  #     }.to change { verification.reload.updated_at }
  #     # .and change { verification.foo }.to('bar') <- example
  #   end
  # end

  # describe 'destroying' do
  #   let!(:verification) { create(:verification) }

  #   let(:instance) do
  #     ResourceVerificationResource.find(id: verification.id)
  #   end

  #   it 'works' do
  #     expect {
  #       expect(instance.destroy).to eq(true)
  #     }.to change { ResourceVerification.count }.by(-1)
  #   end
  # end
end
