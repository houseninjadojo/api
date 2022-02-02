require 'rails_helper'

RSpec.describe SubscriptionPlanResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'subscription-plans',
          attributes: attributes_for(:subscription_plan)
        }
      }
    end

    let(:instance) do
      SubscriptionPlanResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { SubscriptionPlan.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:subscription_plan) { create(:subscription_plan) }

    let(:payload) do
      {
        data: {
          id: subscription_plan.id.to_s,
          type: 'subscription-plans',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      SubscriptionPlanResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { subscription_plan.reload.updated_at }
      # .and change { subscription_plan.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:subscription_plan) { create(:subscription_plan) }

    let(:instance) do
      SubscriptionPlanResource.find(id: subscription_plan.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { SubscriptionPlan.count }.by(-1)
    end
  end
end
