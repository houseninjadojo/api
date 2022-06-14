require 'rails_helper'

RSpec.describe Sync::PromoCode::Stripe::Outbound::CreateJob, type: :job do
  let(:resource) { create(:promo_code) }

  let(:job) { Sync::PromoCode::Stripe::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::PromotionCode).not_to receive(:create)
      job.perform_now(resource)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(resource).params
      idempotency_key = job.new(resource).idempotency_key
      expect(Stripe::PromotionCode).to receive(:create).with(params, {
        idempotency_key: idempotency_key
      }).and_return(double(id: "stripe_token"))
      job.perform_now(resource)
      expect(resource.stripe_id).to eq("stripe_token")
    end
  end

  describe "#policy" do
    it "returns a Sync::PromoCode::Stripe::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::PromoCode::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::PromotionCode.create" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).params).to include(
        {
          coupon: resource.coupon_id,
          code: resource.code,
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
