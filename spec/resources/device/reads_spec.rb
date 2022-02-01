require 'rails_helper'

RSpec.describe DeviceResource, type: :resource do
  describe 'serialization' do
    let!(:device) { create(:device) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(device.id)
      expect(data.jsonapi_type).to eq('devices')
    end
  end

  describe 'filtering' do
    let!(:device1) { create(:device, device_id: 'device-1') }
    let!(:device2) { create(:device, device_id: 'device-2') }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: device2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([device2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
    let!(:device1) { create(:device, device_id: 'device-1') }
    let!(:device2) { create(:device, device_id: 'device-2') }

      context 'when ascending' do
        before do
          params[:sort] = 'device_id'
        end

        it 'works' do
          render
          expect(d.map(&:device_id)).to eq([
            device1.device_id,
            device2.device_id
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-device_id'
        end

        it 'works' do
          render
          expect(d.map(&:device_id)).to eq([
            device2.device_id,
            device1.device_id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
