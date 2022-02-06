require 'rails_helper'

RSpec.describe UserResource, type: :resource do
  describe 'creating' do
    let(:temp_id) { SecureRandom.uuid }
    let(:temp_id_2) { SecureRandom.uuid }

    let(:payload) do
      {
        data: {
          type: 'users',
          attributes: attributes_for(:user).except(:stripe_customer_id, :hubspot_id, :hubspot_contact_object),
          # relationships: {
          #   properties: {
          #     data: [{
          #       type: 'properties',
          #       'temp-id': temp_id,
          #       method: 'create',
          #     }]
          #   }
          # },
          # included: [
          #   {
          #     type: 'properties',
          #     'temp-id': temp_id,
          #     attributes: attributes_for(:property),
          #     # relationships: {
          #     #   address: {
          #     #     data: {
          #     #       type: 'addresses',
          #     #       'temp-id': temp_id_2,
          #     #       method: 'create'
          #     #     }
          #     #   }
          #     # }
          #   },
          #   # {
          #   #   type: 'addresses',
          #   #   'temp-id': temp_id_2,
          #   #   attributes: attributes_for(:address)
          #   # }
          # ]
        }
      }
    end

    let(:instance) do
      UserResource.build(payload)
    end

    it 'works' do
      # binding.pry
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { User.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:user) { create(:user) }

    let(:payload) do
      {
        data: {
          id: user.id.to_s,
          type: 'users',
          attributes: {
            first_name: 'bob'
          }
        }
      }
    end

    let(:instance) do
      UserResource.find(payload)
    end

    it 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { user.reload.updated_at }
      .and change { user.first_name }.to('bob')
    end
  end

  describe 'destroying' do
    let!(:user) { create(:user) }

    let(:instance) do
      UserResource.find(id: user.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { User.count }.by(-1)
    end
  end
end
