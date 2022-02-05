require 'rails_helper'

RSpec.describe SubscriptionResource, type: :resource do
  describe 'creating' do
    let(:user) { create(:user) }
    let(:credit_card) { create(:credit_card) }
    let(:subscription_plan) { create(:subscription_plan) }
    let(:payload) do
      {
        data: {
          type: 'subscriptions',
          # attributes: attributes_for(:subscription),
          attributes: {},
          relationships: {
            payment_method: {
              data: {
                type: 'credit-cards',
                id: credit_card.id,
              }
            },
            subscription_plan: {
              data: {
                type: 'subscription-plans',
                id: subscription_plan.id,
              }
            },
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            },
          },
        },
      }
    end

    let(:instance) do
      SubscriptionResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Subscription.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:subscription) { create(:subscription) }

    let(:payload) do
      {
        data: {
          id: subscription.id.to_s,
          type: 'subscriptions',
          attributes: {}
        }
      }
    end

    let(:instance) do
      SubscriptionResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { subscription.reload.updated_at }
      # .and change { subscription.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:subscription) { create(:subscription) }

    let(:instance) do
      SubscriptionResource.find(id: subscription.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Subscription.count }.by(-1)
    end
  end
end
