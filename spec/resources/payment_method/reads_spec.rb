require 'rails_helper'

RSpec.describe PaymentMethodResource, type: :resource do
  describe 'serialization' do
    let!(:payment_method) { create(:payment_method) }

    xit 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(payment_method.id)
      expect(data.jsonapi_type).to eq('payment_methods')
    end
  end

  describe 'filtering' do
    let!(:payment_method1) { create(:payment_method) }
    let!(:payment_method2) { create(:payment_method) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: payment_method2.id } }
      end

      xit 'works' do
        render
        expect(d.map(&:id)).to eq([payment_method2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:payment_method1) { create(:payment_method) }
      let!(:payment_method2) { create(:payment_method) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        xit 'works' do
          render
          expect(d.map(&:id)).to eq([
            payment_method1.id,
            payment_method2.id
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
            payment_method2.id,
            payment_method1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
