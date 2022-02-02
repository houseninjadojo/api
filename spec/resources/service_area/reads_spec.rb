require 'rails_helper'

RSpec.describe ServiceAreaResource, type: :resource do
  describe 'serialization' do
    let!(:service_area) { create(:service_area) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(service_area.id)
      expect(data.jsonapi_type).to eq('service-areas')
    end
  end

  describe 'filtering' do
    let!(:service_area1) { create(:service_area) }
    let!(:service_area2) { create(:service_area) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: service_area2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([service_area2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by name' do
      let!(:service_area1) { create(:service_area, name: "Austin, TX") }
      let!(:service_area2) { create(:service_area, name: "Dallas, TX") }

      context 'when ascending' do
        before do
          params[:sort] = 'name'
        end

        it 'works' do
          render
          expect(d.map(&:name)).to eq([
            service_area1.name,
            service_area2.name
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-name'
        end

        it 'works' do
          render
          expect(d.map(&:name)).to eq([
            service_area2.name,
            service_area1.name
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
