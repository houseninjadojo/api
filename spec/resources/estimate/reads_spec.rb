require 'rails_helper'

RSpec.describe EstimateResource, type: :resource do
  describe 'serialization' do
    let!(:estimate) { create(:estimate) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(estimate.id)
      expect(data.jsonapi_type).to eq('estimates')
    end
  end

  describe 'filtering' do
    let!(:estimate1) { create(:estimate) }
    let!(:estimate2) { create(:estimate) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: estimate2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([estimate2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:estimate1) { create(:estimate) }
      let!(:estimate2) { create(:estimate) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            estimate1.id,
            estimate2.id
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            estimate2.id,
            estimate1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
