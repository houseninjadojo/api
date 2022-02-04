require 'rails_helper'

RSpec.describe AddressResource, type: :resource do
  describe 'creating' do
    let(:property) { create(:property) }
    let(:payload) do
      {
        data: {
          type: 'addresses',
          attributes: attributes_for(:address),
          relationships: {
            addressible: {
              data: {
                type: 'properties',
                id: property.id
              }
            }
          }
        }
      }
    end

    let(:instance) do
      AddressResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Address.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:address) { create(:address) }

    let(:payload) do
      {
        data: {
          id: address.id.to_s,
          type: 'addresses',
          attributes: {
            city: 'Neverland',
          }
        }
      }
    end

    let(:instance) do
      AddressResource.find(payload)
    end

    xit 'works' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { address.reload.updated_at }
      .and change { address.city }.to('Neverland')
    end
  end

  describe 'destroying' do
    let!(:address) { create(:address) }

    let(:instance) do
      AddressResource.find(id: address.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Address.count }.by(-1)
    end
  end
end
