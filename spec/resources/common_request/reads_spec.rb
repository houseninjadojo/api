require 'rails_helper'

RSpec.describe CommonRequestResource, type: :resource do
  describe 'serialization' do
    let!(:common_request) { create(:common_request) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(common_request.id)
      expect(data.jsonapi_type).to eq('common-requests')
    end
  end

  describe 'filtering' do
    let!(:common_request1) { create(:common_request) }
    let!(:common_request2) { create(:common_request) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: common_request2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([common_request2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:common_request1) { create(:common_request, caption: 'a b c') }
      let!(:common_request2) { create(:common_request, caption: 'd e f') }

      context 'when ascending' do
        before do
          params[:sort] = 'caption'
        end

        it 'works' do
          render
          expect(d.map(&:caption)).to eq([
            common_request1.caption,
            common_request2.caption
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-caption'
        end

        it 'works' do
          render
          expect(d.map(&:caption)).to eq([
            common_request2.caption,
            common_request1.caption
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
