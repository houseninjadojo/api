require 'rails_helper'

RSpec.describe WorkOrderResource, type: :resource do
  describe 'serialization' do
    let!(:work_order) { create(:work_order) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(work_order.id)
      expect(data.jsonapi_type).to eq('work-orders')
    end
  end

  describe 'filtering' do
    let!(:work_order1) { create(:work_order) }
    let!(:work_order2) { create(:work_order) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: work_order2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([work_order2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by vendor' do
      let!(:work_order1) { create(:work_order, vendor: 'a b c') }
      let!(:work_order2) { create(:work_order, vendor: 'd e f') }

      context 'when ascending' do
        before do
          params[:sort] = 'vendor'
        end

        it 'works' do
          render
          expect(d.map(&:vendor)).to eq([
            work_order1.vendor,
            work_order2.vendor
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-vendor'
        end

        it 'works' do
          render
          expect(d.map(&:vendor)).to eq([
            work_order2.vendor,
            work_order1.vendor
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
