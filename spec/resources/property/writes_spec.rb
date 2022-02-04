require 'rails_helper'

RSpec.describe PropertyResource, type: :resource do
  let(:user) { create(:user) }
  let(:temp_id) { SecureRandom.uuid }
  let(:service_area) { create(:service_area) }

  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'properties',
          attributes: attributes_for(:property),
          relationships: {
            service_area: {
              data: {
                type: 'service-areas',
                id: service_area.id
              }
            },
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            }
          }
        }
      }
    end

    let(:instance) do
      PropertyResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Property.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:property) { create(:property) }

    let(:payload) do
      {
        data: {
          id: property.id.to_s,
          type: 'properties',
          attributes: {
            lot_size: 123_456
          }
        }
      }
    end

    let(:instance) do
      PropertyResource.find(payload)
    end

    it 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { property.reload.updated_at }
      .and change { property.lot_size }.to(123_456)
    end
  end

  describe 'destroying' do
    let!(:property) { create(:property) }

    let(:instance) do
      PropertyResource.find(id: property.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Property.count }.by(-1)
    end
  end
end
