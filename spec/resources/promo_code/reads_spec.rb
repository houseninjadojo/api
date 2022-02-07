require 'rails_helper'

RSpec.describe PromoCodeResource, type: :resource do
  describe 'serialization' do
    let!(:promo_code) { create(:promo_code) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(promo_code.id)
      expect(data.jsonapi_type).to eq('promo-codes')
    end
  end

  describe 'filtering' do
    let!(:promo_code1) { create(:promo_code) }
    let!(:promo_code2) { create(:promo_code) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: promo_code2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([promo_code2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by name' do
      let!(:promo_code1) { create(:promo_code, name: "a") }
      let!(:promo_code2) { create(:promo_code, name: "b") }

      context 'when ascending' do
        before do
          params[:sort] = 'name'
        end

        it 'works' do
          render
          expect(d.map(&:name)).to eq([
            promo_code1.name,
            promo_code2.name
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
            promo_code2.name,
            promo_code1.name
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
