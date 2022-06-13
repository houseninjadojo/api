require 'rails_helper'

RSpec.describe Sync::Subscription::Stripe::Outbound::CreateJob, type: :job do
  let(:resource) { create(:subscription) }

  let(:job) { Sync::Subscription::Stripe::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Subscription).not_to receive(:create)
      job.perform_now(resource)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(resource).params
      idempotency_key = job.new(resource).idempotency_key
      expect(Stripe::Subscription).to receive(:create).with(params, {
        idempotency_key: idempotency_key
      }).and_return(double(
        id: "stripe_token",
        status: "active",
        current_period_start: Time.zone.now.to_i,
        current_period_end: Time.zone.now.to_i + 1.month,
        trial_start: Time.zone.now.to_i,
        trial_end: Time.zone.now.to_i + 1.month,
      ))
      job.perform_now(resource)
      expect(resource.stripe_id).to eq("stripe_token")
    end
  end

  describe "#policy" do
    it "returns a Sync::Subscription::Stripe::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::Subscription::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Subscription.create" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).params).to include(
        {
          collection_method: "charge_automatically",
          customer: resource.user.stripe_id,
          default_payment_method: resource.payment_method.stripe_id,
          items: [
            { price: resource.subscription_plan.stripe_price_id },
          ],
          promotion_code: resource.promo_code&.stripe_id,
          payment_behavior: 'error_if_incomplete',
          metadata: {
            house_ninja_id: resource.id,
          },
        }
      )
    end
  end

  describe "#idempotency_key" do
    it "returns idempotency key" do
      key = Digest::SHA256.hexdigest("#{resource.id}#{resource.updated_at.to_i}")
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).idempotency_key).to eq(key)
    end
  end
end
