require 'rails_helper'

RSpec.describe CreditCardResource, type: :resource do
  describe 'serialization' do
    let!(:credit_card) { create(:credit_card) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(credit_card.id)
      expect(data.jsonapi_type).to eq('credit-cards')
    end
  end

  describe 'filtering' do
    let!(:credit_card1) { create(:credit_card) }
    let!(:credit_card2) { create(:credit_card) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: credit_card2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([credit_card2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:credit_card1) { create(:credit_card, zipcode: '12345') }
      let!(:credit_card2) { create(:credit_card, zipcode: '54321') }

      context 'when ascending' do
        before do
          params[:sort] = 'zipcode'
        end

        it 'works' do
          render
          expect(d.map(&:zipcode)).to eq([
            credit_card1.zipcode,
            credit_card2.zipcode
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-zipcode'
        end

        it 'works' do
          render
          expect(d.map(&:zipcode)).to eq([
            credit_card2.zipcode,
            credit_card1.zipcode
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
