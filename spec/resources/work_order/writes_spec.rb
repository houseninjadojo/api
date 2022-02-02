require 'rails_helper'

RSpec.describe WorkOrderResource, type: :resource do
  describe 'creating' do
    let(:property) { create(:property) }
    let(:payload) do
      {
        data: {
          type: 'work-orders',
          attributes: attributes_for(:work_order),
          relationships: {
            property: {
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
      WorkOrderResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { WorkOrder.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:work_order) { create(:work_order) }

    let(:payload) do
      {
        data: {
          id: work_order.id.to_s,
          type: 'work-orders',
          attributes: {
            vendor: 'a b c',
          }
        }
      }
    end

    let(:instance) do
      WorkOrderResource.find(payload)
    end

    it 'works' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { work_order.reload.updated_at }
      .and change { work_order.vendor }.to('a b c')
    end
  end

  describe 'destroying' do
    let!(:work_order) { create(:work_order) }

    let(:instance) do
      WorkOrderResource.find(id: work_order.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { WorkOrder.count }.by(-1)
    end
  end
end
