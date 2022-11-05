require 'rails_helper'

RSpec.describe Sync::Webhook::StripeJob, type: :job do
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
  let(:job) { Sync::Webhook::StripeJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Sync::PromoCode::Stripe::Inbound::CreateJob).not_to receive(:perform_now)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to receive(:payload).and_return(webhook_event.payload)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(Sync::PromoCode::Stripe::Inbound::CreateJob).to receive(:perform_now).with(webhook_event)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::Webhook::StripePolicy)
    end
  end

  describe "#resource_klass" do
    it "returns a resource class" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(job.new(webhook_event).resource_klass).to eq(PromoCode)
    end
  end

  describe "#handler_action" do
    it "returns an action" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(job.new(webhook_event).handler_action).to eq(:create)
    end
  end

  describe "#handler" do
    it "returns a handler" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      expect(job.new(webhook_event).handler).to eq(Sync::PromoCode::Stripe::Inbound::CreateJob)
    end
  end
end
