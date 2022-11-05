require "rails_helper"

RSpec.describe Sync::Subscription::Stripe::Inbound::UpdatePolicy, type: :policy do
  let(:subscription) { create(:subscription, stripe_id: 'asdf', status: 'active') }
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
  let(:policy) { described_class.new(payload, webhook_event: webhook_event) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:is_new_record?).and_return(false)
      expect(policy).to receive(:is_active?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:is_new_record?).and_return(false)
      expect(policy).to receive(:is_active?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if external id present" do
      payload[:data][:object][:id] = '1234'
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if external id not present" do
      payload[:data][:object][:id] = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :is_active? do
    it "returns true if is_active" do
      subscription.status = 'active'
      expect(policy.is_active?).to be_truthy
    end

    it "returns false if does not is_active?" do
      allow_any_instance_of(Subscription).to receive(:active?).and_return(false)
      expect(policy.is_active?).to be_falsey
    end
  end

  describe_rule :is_new_record? do
    it "returns true if resource does not exist" do
      allow(Subscription).to receive(:exists?).and_return(false)
      expect(policy.is_new_record?).to be_truthy
    end

    it "returns false if resource already exits" do
      invoice = create(:invoice, stripe_id: 'in_1LAk6PAWN1SYQ0CtCC1pSWvD')
      expect(policy.is_new_record?).to be_falsey
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
end
