require 'rails_helper'

RSpec.describe ServiceAreaResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'service-areas',
          attributes: attributes_for(:service_area)
        }
      }
    end

    let(:instance) do
      ServiceAreaResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { ServiceArea.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:service_area) { create(:service_area) }

    let(:payload) do
      {
        data: {
          id: service_area.id.to_s,
          type: 'service-areas',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      ServiceAreaResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { service_area.reload.updated_at }
      # .and change { service_area.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:service_area) { create(:service_area) }

    let(:instance) do
      ServiceAreaResource.find(id: service_area.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { ServiceArea.count }.by(-1)
    end
  end
end
