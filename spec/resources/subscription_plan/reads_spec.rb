require 'rails_helper'

RSpec.describe SubscriptionPlanResource, type: :resource do
  describe 'serialization' do
    let!(:subscription_plan) { create(:subscription_plan) }

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(subscription_plan.id)
      expect(data.jsonapi_type).to eq('subscription-plans')
    end
  end

  describe 'filtering' do
    let!(:subscription_plan1) { create(:subscription_plan, slug: 'annual') }
    let!(:subscription_plan2) { create(:subscription_plan, slug: 'monthly') }

    context 'by slug' do
      before do
        params[:filter] = { slug: { eq: subscription_plan2.slug } }
      end

      it 'works' do
        render
        expect(d.map(&:slug)).to eq([subscription_plan2.slug])
      end
    end
  end

  describe 'sorting' do
    describe 'by slug' do
      let!(:subscription_plan1) { create(:subscription_plan, slug: 'annual') }
      let!(:subscription_plan2) { create(:subscription_plan, slug: 'monthly') }

      context 'when ascending' do
        before do
          params[:sort] = 'slug'
        end

        it 'works' do
          render
          expect(d.map(&:slug)).to eq([
            subscription_plan1.slug,
            subscription_plan2.slug
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-slug'
        end

        it 'works' do
          render
          expect(d.map(&:slug)).to eq([
            subscription_plan2.slug,
            subscription_plan1.slug
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
