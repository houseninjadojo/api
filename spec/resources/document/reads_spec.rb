require 'rails_helper'

RSpec.describe DocumentResource, type: :resource do
  describe 'serialization' do
    let!(:document) { create(:document) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(document.id)
      expect(data.jsonapi_type).to eq('documents')
    end
  end

  describe 'filtering' do
    let!(:document1) { create(:document) }
    let!(:document2) { create(:document) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: document2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([document2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by name' do
      let!(:document1) { create(:document, name: 'a') }
      let!(:document2) { create(:document, name: 'b') }

      context 'when ascending' do
        before do
          params[:sort] = 'name'
        end

        it 'works' do
          render
          expect(d.map(&:name)).to eq([
            document1.name,
            document2.name
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
            document2.name,
            document1.name
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
