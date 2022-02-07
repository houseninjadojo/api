require 'rails_helper'

RSpec.describe InvoiceResource, type: :resource do
  describe 'serialization' do
    let!(:invoice) { create(:invoice) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(invoice.id)
      expect(data.jsonapi_type).to eq('invoices')
    end
  end

  describe 'filtering' do
    let!(:invoice1) { create(:invoice) }
    let!(:invoice2) { create(:invoice) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: invoice2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([invoice2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by status' do
      let!(:invoice1) { create(:invoice, status: "draft") }
      let!(:invoice2) { create(:invoice, status: "open") }

      context 'when ascending' do
        before do
          params[:sort] = 'status'
        end

        it 'works' do
          render
          expect(d.map(&:status)).to eq([
            invoice1.status,
            invoice2.status
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-status'
        end

        it 'works' do
          render
          expect(d.map(&:status)).to eq([
            invoice2.status,
            invoice1.status
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
