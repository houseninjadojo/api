require 'rails_helper'

RSpec.describe LineItemResource, type: :resource do
  describe 'serialization' do
    let!(:line_item) { create(:line_item) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(line_item.id)
      expect(data.jsonapi_type).to eq('line-items')
    end
  end

  describe 'filtering' do
    let!(:line_item1) { create(:line_item, name: 'a') }
    let!(:line_item2) { create(:line_item, name: 'b') }

    context 'by name' do
      before do
        params[:filter] = { name: { eq: line_item2.name } }
      end

      it 'works' do
        render
        expect(d.map(&:name)).to eq([line_item2.name])
      end
    end
  end

  describe 'sorting' do
    describe 'by name' do
      let!(:line_item1) { create(:line_item, name: 'a') }
      let!(:line_item2) { create(:line_item, name: 'b') }

      context 'when ascending' do
        before do
          params[:sort] = 'name'
        end

        it 'works' do
          render
          expect(d.map(&:name)).to eq([
            line_item1.name,
            line_item2.name
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
            line_item2.name,
            line_item1.name
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
