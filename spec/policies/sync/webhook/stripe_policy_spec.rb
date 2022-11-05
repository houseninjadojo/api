require "rails_helper"

RSpec.describe Sync::Webhook::StripePolicy, type: :policy do
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
            "metadata": {},
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
          "metadata": {},
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
  let(:policy) { described_class.new(webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(false)
      expect(policy).to receive(:enabled?).and_return(true)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :webhook_is_unprocessed? do
    it "returns true if webhook is unprocessed" do
      webhook_event.processed_at = nil
      expect(policy.webhook_is_unprocessed?).to be_truthy
    end

    it "returns false if webhook was already processed" do
      webhook_event.processed_at = Time.now
      expect(policy.webhook_is_unprocessed?).to be_falsey
    end
  end

  describe_rule :enabled? do
    it "returns true if handler enabled" do
      allow(ENV).to receive(:[]).with('STRIPE_WEBHOOK_DISABLED').and_return(nil)
      expect(policy.enabled?).to be_truthy
    end

    it "returns false if handler disabled" do
      allow(ENV).to receive(:[]).with('STRIPE_WEBHOOK_DISABLED').and_return("true")
      expect(policy.enabled?).to be_falsey
    end
  end
end
