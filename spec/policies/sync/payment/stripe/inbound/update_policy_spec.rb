require "rails_helper"

RSpec.describe Sync::Payment::Stripe::Inbound::UpdatePolicy, type: :policy do
  let(:payload) {
    {
      # "id": "evt_3LB9CoAWN1SYQ0Ct03V9O47R",
      # "object": "event",
      # "api_version": "2020-08-27",
      # "created": 1655349931,
      "data": {
        "object": {
          "id": "ch_3LB9CoAWN1SYQ0Ct0hwvoo6Z",
          "object": "charge",
          "amount": 5000,
          "amount_captured": 5000,
          "amount_refunded": 0,
          "application": nil,
          "application_fee": nil,
          "application_fee_amount": nil,
          "balance_transaction": "txn_3LB9CoAWN1SYQ0Ct0ztNkXiU",
          "billing_details": {
            "address": {
              "city": nil,
              "country": nil,
              "line1": nil,
              "line2": nil,
              "postal_code": nil,
              "state": nil
            },
            "email": nil,
            "name": nil,
            "phone": nil
          },
          "calculated_statement_descriptor": "HOUSE NINJA, INC.",
          "captured": true,
          "created": 1655349930,
          "currency": "usd",
          "customer": "cus_Ls48MT9ISdBDcp",
          "description": "Payment for Invoice",
          "destination": nil,
          "dispute": nil,
          "disputed": false,
          "failure_balance_transaction": nil,
          "failure_code": nil,
          "failure_message": nil,
          "fraud_details": {
          },
          "invoice": "in_1LAoJTAWN1SYQ0Ct5gdCBKvd",
          "livemode": false,
          "metadata": {
          },
          "on_behalf_of": nil,
          "order": nil,
          "outcome": {
            "network_status": "approved_by_network",
            "reason": nil,
            "risk_level": "normal",
            "risk_score": 37,
            "seller_message": "Payment complete.",
            "type": "authorized"
          },
          "paid": true,
          "payment_intent": "pi_3LB9CoAWN1SYQ0Ct0a9BQvow",
          "payment_method": "src_1LB9KmAWN1SYQ0CtKIU0ChiK",
          "payment_method_details": {
            "card": {
              "brand": "visa",
              "checks": {
                "address_line1_check": nil,
                "address_postal_code_check": nil,
                "cvc_check": "pass"
              },
              "country": "US",
              "exp_month": 12,
              "exp_year": 2023,
              "fingerprint": "xW507BzGg885nTAd",
              "funding": "credit",
              "installments": nil,
              "last4": "4242",
              "mandate": nil,
              "network": "visa",
              "three_d_secure": nil,
              "wallet": nil
            },
            "type": "card"
          },
          "receipt_email": nil,
          "receipt_number": nil,
          "receipt_url": "https://pay.stripe.com/receipts/acct_1IH0d5AWN1SYQ0Ct/ch_3LB9CoAWN1SYQ0Ct0hwvoo6Z/rcpt_LsvBdWN2xdpHzDtzTh0rRqdkbkQEvr4",
          "refunded": false,
          "refunds": {
            "object": "list",
            "data": [],
            "has_more": false,
            "total_count": 0,
            "url": "/v1/charges/ch_3LB9CoAWN1SYQ0Ct0hwvoo6Z/refunds"
          },
          "review": nil,
          "shipping": nil,
          "source": nil,
          "source_transfer": nil,
          "statement_descriptor": nil,
          "statement_descriptor_suffix": nil,
          "status": "succeeded",
          "transfer_data": nil,
          "transfer_group": nil
        }
      }
      # "livemode": false,
      # "pending_webhooks": 3,
      # "request": {
      #   "id": "req_FzlJaaikWKu7lv",
      #   "idempotency_key": "f9b0ec77-1ac4-4aee-a5cb-602abcd8bc8d"
      # },
      # "type": "charge.succeeded"
    }
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
      expect(policy).to receive(:resource_exists?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:webhook_is_unprocessed?).and_return(true)
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:resource_exists?).and_return(false)
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

  describe_rule :resource_exists? do
    it "returns false if resource does not exist" do
      expect(policy.resource_exists?).to be_falsey
    end

    it "returns true if resource already exits" do
      payment = create(:payment, :with_invoice, stripe_id: 'ch_3LB9CoAWN1SYQ0Ct0hwvoo6Z')
      expect(policy.resource_exists?).to be_truthy
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
