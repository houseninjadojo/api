require 'rails_helper'

RSpec.describe PropertyResource, type: :resource do
  describe 'serialization' do
    let!(:property) { create(:property) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(property.id)
      expect(data.jsonapi_type).to eq('properties')
    end
  end

  describe 'filtering' do
    let!(:property1) { create(:property) }
    let!(:property2) { create(:property) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: property2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([property2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:property1) { create(:property) }
      let!(:property2) { create(:property) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            property1.id,
            property2.id
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
            property2.id,
            property1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
