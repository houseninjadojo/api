require 'rails_helper'

RSpec.describe DocumentGroupResource, type: :resource do
  describe 'serialization' do
    let!(:document_group) { create(:document_group) }

    xit 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(document_group.id)
      expect(data.jsonapi_type).to eq('document-groups')
    end
  end

  describe 'filtering' do
    let!(:document_group1) { create(:document_group) }
    let!(:document_group2) { create(:document_group) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: document_group2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([document_group2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by name' do
      let!(:document_group1) { create(:document_group, name: 'a') }
      let!(:document_group2) { create(:document_group, name: 'b') }

      context 'when ascending' do
        before do
          params[:sort] = 'name'
        end

        xit 'works' do
          render
          expect(d.map(&:name)).to eq([
            document_group1.name,
            document_group2.name
          ].concat(DocumentGroup::DEFAULT_GROUPS).sort)
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-name'
        end

        xit 'works' do
          render
          expect(d.map(&:name)).to eq([
            document_group2.name,
            document_group1.name
          ].concat(DocumentGroup::DEFAULT_GROUPS).sort)
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
