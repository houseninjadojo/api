require 'rails_helper'

RSpec.describe PropertyResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'properties',
          attributes: attributes_for(:property)
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
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      PropertyResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { property.reload.updated_at }
      # .and change { property.foo }.to('bar') <- example
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
