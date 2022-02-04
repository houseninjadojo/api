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
      let!(:property1) { create(:property, lot_size: 5) }
      let!(:property2) { create(:property, lot_size: 10) }

      context 'when ascending' do
        before do
          params[:sort] = 'lot_size'
        end

        xit 'works' do
          render
          expect(d.map(&:lot_size)).to eq([
            property1.lot_size,
            property2.lot_size
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-lot_size'
        end

        xit 'works' do
          render
          expect(d.map(&:lot_size)).to eq([
            property2.lot_size,
            property1.lot_size
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    let(:user) { create(:user) }

    describe 'user' do
      let!(:property) { create(:property, user: user) }

      before do
        params[:include] = 'user'
      end

      it 'sideloads user relationship' do
        render
        a = d[0].sideload(:user)
        expect(a.jsonapi_type).to eq('users')
        expect(a.id).to eq(user.id)
      end
    end
  end
end
