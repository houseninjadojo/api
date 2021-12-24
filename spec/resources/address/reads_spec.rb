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
    describe 'by id' do
      let!(:address1) { create(:address) }
      let!(:address2) { create(:address) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            address1.id,
            address2.id
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
            address2.id,
            address1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
