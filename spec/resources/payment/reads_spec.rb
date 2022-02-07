require 'rails_helper'

RSpec.describe PaymentResource, type: :resource do
  describe 'serialization' do
    let!(:payment) { create(:payment, :with_relationships) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(payment.id)
      expect(data.jsonapi_type).to eq('payments')
    end
  end

  describe 'filtering' do
    let!(:payment1) { create(:payment, :with_relationships) }
    let!(:payment2) { create(:payment, :with_relationships) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: payment2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([payment2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by status' do
      let!(:payment1) { create(:payment, :with_relationships, status: "a") }
      let!(:payment2) { create(:payment, :with_relationships, status: "b") }

      context 'when ascending' do
        before do
          params[:sort] = 'status'
        end

        it 'works' do
          render
          expect(d.map(&:status)).to eq([
            payment1.status,
            payment2.status
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
            payment2.status,
            payment1.status
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
