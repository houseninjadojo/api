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
    describe 'by created_at' do
      let!(:estimate1) { create(:estimate, created_at: DateTime.now) }
      let!(:estimate2) { create(:estimate, created_at: DateTime.now + 1.hour) }

      context 'when ascending' do
        before do
          params[:sort] = 'created_at'
        end

        it 'works' do
          render
          expect(d.map(&:created_at)).to eq([
            datetime(estimate1.created_at),
            datetime(estimate2.created_at)
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-created_at'
        end

        it 'works' do
          render
          expect(d.map(&:created_at)).to eq([
            datetime(estimate2.created_at),
            datetime(estimate1.created_at)
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
