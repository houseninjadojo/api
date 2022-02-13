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
    describe 'by id' do
      let!(:document1) { create(:document) }
      let!(:document2) { create(:document) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        xit 'works' do
          render
          expect(d.map(&:id)).to eq([
            document1.id,
            document2.id
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-id'
        end

        xit 'works' do
          render
          expect(d.map(&:id)).to eq([
            document2.id,
            document1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
