require 'rails_helper'

RSpec.describe AddressResource, type: :resource do
  describe 'serialization' do
    let!(:address) { create(:address) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(address.id)
      expect(data.jsonapi_type).to eq('addresses')
    end
  end

  describe 'filtering' do
    let!(:address1) { create(:address) }
    let!(:address2) { create(:address) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: address2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([address2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by city' do
      let!(:address1) { create(:address, city: 'Austin' ) }
      let!(:address2) { create(:address, city: 'Zion') }

      context 'when ascending' do
        before do
          params[:sort] = 'city'
        end

        it 'works' do
          render
          expect(d.map(&:city)).to eq([
            address1.city,
            address2.city
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-city'
        end

        it 'works' do
          render
          expect(d.map(&:city)).to eq([
            address2.city,
            address1.city
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    let(:address) { create(:address) }

    describe 'addressible' do
      let!(:property) { create(:property, address: address) }

      before do
        params[:include] = 'addressible'
      end

      it 'sideloads property relationship' do
        render
        a = d[0].sideload(:addressible)
        expect(a.jsonapi_type).to eq('properties')
        expect(a.id).to eq(property.id)
      end
    end
  end
end
