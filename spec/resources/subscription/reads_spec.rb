require 'rails_helper'

RSpec.describe SubscriptionResource, type: :resource do
  describe 'serialization' do
    let!(:subscription) { create(:subscription) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(subscription.id)
      expect(data.jsonapi_type).to eq('subscriptions')
    end
  end

  describe 'filtering' do
    let!(:subscription1) { create(:subscription) }
    let!(:subscription2) { create(:subscription) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: subscription2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([subscription2.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by status' do
      let!(:subscription1) { create(:subscription, status: "active") }
      let!(:subscription2) { create(:subscription, status: "canceled") }

      context 'when ascending' do
        before do
          params[:sort] = 'status'
        end

        it 'works' do
          render
          expect(d.map(&:status)).to eq([
            subscription1.status,
            subscription2.status
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
            subscription2.status,
            subscription1.status
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
