require 'rails_helper'

RSpec.describe Sync::PromoCode::Stripe::Inbound::CreateJob, type: :job do
  let(:promo_code) {
    create(:promo_code,
      stripe_id: 'promo_1KYdROAWN1SYQ0CtylED88jt',
      name: 'TEST CODE',
      code: 'test',
    )
  }
  let(:payload) {
    {
      "id": "evt_1L9ES2AWN1SYQ0CtpEslNipz",
      "object": "event",
      "api_version": "2020-08-27",
      "created": 1654892941,
      "data": {
        "object": {
          "id": "promo_1KYdROAWN1SYQ0CtylED88jt",
          "object": "promotion_code",
          "active": true,
          "code": "test",
          "coupon": {
            "id": "VeNkKlf7",
            "object": "coupon",
            "amount_off": nil,
            "created": 1654892941,
            "currency": nil,
            "duration": "forever",
            "duration_in_months": nil,
            "livemode": true,
            "max_redemptions": nil,
            "metadata": {
            },
            "name": "TEST CODE",
            "percent_off": 100,
            "redeem_by": nil,
            "times_redeemed": 0,
            "valid": true
          },
          "created": 1654892941,
          "customer": nil,
          "expires_at": nil,
          "livemode": true,
          "max_redemptions": nil,
          "metadata": {
          },
          "restrictions": {
            "first_time_transaction": false,
            "minimum_amount": nil,
            "minimum_amount_currency": nil
          },
          "times_redeemed": 0
        }
      },
      "livemode": true,
      "pending_webhooks": 1,
      "request": {
        "id": "req_2RoElzkMCvhz7p",
        "idempotency_key": "04f7da01-01c1-4e91-90a4-30bf3a88b30b"
      },
      "type": "promotion_code.created"
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'stripe',
      payload: payload
    )
  }
  let(:job) { Sync::PromoCode::Stripe::Inbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(PromoCode).not_to receive(:create!)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      # expect(PromoCode).to receive(:find_coupon_by).and_return(nil)
      expect(PromoCode).to receive(:create!).with({
        active: true,
        code: "test",
        name: "TEST CODE",
        percent_off: 100,
        duration: "forever",
        # amount_off: nil,
        coupon_id: "VeNkKlf7",
        created_at: Time.at(1654892941),
        stripe_id: "promo_1KYdROAWN1SYQ0CtylED88jt",
        stripe_object: payload[:data][:object].to_json,
      })
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::PromoCode::Stripe::Inbound::CreatePolicy)
    end
  end

  describe "#stripe_event" do
    it "returns a Stripe::Event" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).stripe_event).to be_a(Stripe::Event)
    end
  end

  describe "#params" do
    it "returns params" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).params).to include(
        active: true,
        code: "test",
        name: "TEST CODE",
        duration: "forever",
        percent_off: 100,
        # amount_off: nil,
        coupon_id: "VeNkKlf7",
        created_at: Time.at(1654892941),
        stripe_id: "promo_1KYdROAWN1SYQ0CtylED88jt",
        stripe_object: payload[:data][:object].to_json,
      )
    end
  end
end
