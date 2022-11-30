require 'rails_helper'

RSpec.describe Sync::Subscription::Stripe::Inbound::UpdateJob, type: :job do
  let(:subscription) { create(:subscription, stripe_id: "asdf") }
  let(:payload) {
    {
      "id": "evt_1LIwqOAWN1SYQ0Ct7AOgdSfh",
      "object": "event",
      "api_version": "2020-08-27",
      "created": 1657208539,
      "data": {
        "object": {
          "id": "asdf",
          "object": "subscription",
          "application": nil,
          "application_fee_percent": nil,
          "automatic_tax": {
            "enabled": false
          },
          "billing_cycle_anchor": 1657208362,
          "billing_thresholds": nil,
          "cancel_at": nil,
          "cancel_at_period_end": false,
          "canceled_at": 1657208539,
          "collection_method": "charge_automatically",
          "created": 1657208362,
          "current_period_end": 1659886762,
          "current_period_start": 1657208362,
          "customer": "cus_M0icWc8UyTLduY",
          "days_until_due": nil,
          "default_payment_method": "pm_1LIhBKAWN1SYQ0CtTppIJ6xE",
          "default_source": nil,
          "default_tax_rates": [],
          "description": nil,
          "discount": {
            "id": "di_1LIwnXAWN1SYQ0Ct0IKJJQYu",
            "object": "discount",
            "checkout_session": nil,
            "coupon": {
              "id": "Uz8oOt9R",
              "object": "coupon",
              "amount_off": nil,
              "created": 1648535128,
              "currency": nil,
              "duration": "repeating",
              "duration_in_months": 6,
              "livemode": true,
              "max_redemptions": nil,
              "metadata": {},
              "name": "Six Months Free",
              "percent_off": 100,
              "redeem_by": nil,
              "times_redeemed": 2,
              "valid": true
            },
            "customer": "cus_M0icWc8UyTLduY",
            "end": 1673105962,
            "invoice": nil,
            "invoice_item": nil,
            "promotion_code": "promo_1KiYmhAWN1SYQ0Ctj4bO1hL0",
            "start": 1657208362,
            "subscription": "sub_1LIwnXAWN1SYQ0CtxWTsjvMJ"
          },
          "ended_at": 1657208539,
          "items": {
            "object": "list",
            "data": [
              {
                "id": "si_M0ylkjGuH87yMy",
                "object": "subscription_item",
                "billing_thresholds": nil,
                "created": 1657208363,
                "metadata": {},
                "plan": {
                  "id": "price_1Ie6wdAWN1SYQ0CtKiaqMHcA",
                  "object": "plan",
                  "active": true,
                  "aggregate_usage": nil,
                  "amount": 2900,
                  "amount_decimal": "2900",
                  "billing_scheme": "per_unit",
                  "created": 1617923247,
                  "currency": "usd",
                  "interval": "month",
                  "interval_count": 1,
                  "livemode": true,
                  "metadata": {},
                  "nickname": nil,
                  "product": "prod_J1eBMo47WiDtcH",
                  "tiers_mode": nil,
                  "transform_usage": nil,
                  "trial_period_days": nil,
                  "usage_type": "licensed"
                },
                "price": {
                  "id": "price_1Ie6wdAWN1SYQ0CtKiaqMHcA",
                  "object": "price",
                  "active": true,
                  "billing_scheme": "per_unit",
                  "created": 1617923247,
                  "currency": "usd",
                  "custom_unit_amount": nil,
                  "livemode": true,
                  "lookup_key": nil,
                  "metadata": {},
                  "nickname": nil,
                  "product": "prod_J1eBMo47WiDtcH",
                  "recurring": {
                    "aggregate_usage": nil,
                    "interval": "month",
                    "interval_count": 1,
                    "trial_period_days": nil,
                    "usage_type": "licensed"
                  },
                  "tax_behavior": "unspecified",
                  "tiers_mode": nil,
                  "transform_quantity": nil,
                  "type": "recurring",
                  "unit_amount": 2900,
                  "unit_amount_decimal": "2900"
                },
                "quantity": 1,
                "subscription": "sub_1LIwnXAWN1SYQ0CtxWTsjvMJ",
                "tax_rates": []
              }
            ],
            "has_more": false,
            "total_count": 1,
            "url": "/v1/subscription_items?subscription=sub_1LIwnXAWN1SYQ0CtxWTsjvMJ"
          },
          "latest_invoice": "in_1LIwnXAWN1SYQ0CtBIhy2J7w",
          "livemode": true,
          "metadata": {
            "house_ninja_id": subscription.id,
          },
          "next_pending_invoice_item_invoice": nil,
          "pause_collection": nil,
          "payment_settings": {
            "payment_method_options": nil,
            "payment_method_types": nil,
            "save_default_payment_method": "off"
          },
          "pending_invoice_item_interval": nil,
          "pending_setup_intent": nil,
          "pending_update": nil,
          "plan": {
            "id": "price_1Ie6wdAWN1SYQ0CtKiaqMHcA",
            "object": "plan",
            "active": true,
            "aggregate_usage": nil,
            "amount": 2900,
            "amount_decimal": "2900",
            "billing_scheme": "per_unit",
            "created": 1617923247,
            "currency": "usd",
            "interval": "month",
            "interval_count": 1,
            "livemode": true,
            "metadata": {},
            "nickname": nil,
            "product": "prod_J1eBMo47WiDtcH",
            "tiers_mode": nil,
            "transform_usage": nil,
            "trial_period_days": nil,
            "usage_type": "licensed"
          },
          "quantity": 1,
          "schedule": nil,
          "start_date": 1657208362,
          "status": "canceled",
          "test_clock": nil,
          "transfer_data": nil,
          "trial_end": nil,
          "trial_start": nil
        }
      },
      "livemode": true,
      "pending_webhooks": 2,
      "request": {
        "id": "req_mPaqFS3oPAka12",
        "idempotency_key": nil
      },
      "type": "customer.subscription.deleted"
    }.with_indifferent_access
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'stripe',
      payload: payload
    )
  }
  let(:job) { Sync::Subscription::Stripe::Inbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(subscription).not_to receive(:update!)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      subscription_object = object_double(Stripe::Event.construct_from(payload).data.object)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      allow_any_instance_of(job).to receive(:webhook_event).and_return(webhook_event)
      params = job.new(webhook_event).params
      expect_any_instance_of(Subscription).to receive(:update!).with({
        status: 'canceled',
        stripe_object: Stripe::Event.construct_from(payload).data.object.as_json,
      })
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::Subscription::Stripe::Inbound::UpdatePolicy)
    end
  end

  describe "#stripe_event" do
    it "returns a Stripe::Event" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).stripe_event).to be_a(Stripe::Event)
    end
  end

  describe "#stripe_object" do
    it "returns a Stripe::Event" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).stripe_object).to be_a(Stripe::Subscription)
    end
  end

  describe "#params" do
    it "returns params" do
      subscription_object = object_double(Stripe::Event.construct_from(payload).data.object)
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      allow(Stripe::Subscription).to receive(:retrieve).and_return(subscription_object)
      expect(job.new(webhook_event).params).to include(
        status: 'canceled',
        stripe_object: Stripe::Event.construct_from(payload).data.object,
      )
    end
  end
end
