require 'rails_helper'

RSpec.describe DeviceResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'devices',
          attributes: attributes_for(:device)
        }
      }
    end

    let(:instance) do
      DeviceResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Device.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:device) { create(:device) }

    let(:payload) do
      {
        data: {
          id: device.id.to_s,
          type: 'devices',
          attributes: {
            device_id: 'test-device-id'
          } # Todo!
        }
      }
    end

    let(:instance) do
      DeviceResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { device.reload.updated_at }
      .and change { device.device_id }.to('test-device-id')
    end
  end

  describe 'destroying' do
    let!(:device) { create(:device) }

    let(:instance) do
      DeviceResource.find(id: device.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Device.count }.by(-1)
    end
  end
end
