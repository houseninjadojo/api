require 'rails_helper'

RSpec.describe Sync::Payment::Stripe::Inbound::UpdateJob, type: :job do
  let(:user) { create(:user, stripe_id: "cus_LVeJwkMEn3BBnE") }
  let(:invoice) {
    create(:invoice,
      stripe_id: 'in_1LAk6PAWN1SYQ0CtCC1pSWvD',
      total: 5000,
      user: user
    )
  }
  let(:payment_method) { create(:credit_card, stripe_token: "pm_1Kod0ZAWN1SYQ0CtRiUcGEhe") }
  let(:payment) {
    create(:payment,
      stripe_id: 'ch_3LB9CoAWN1SYQ0Ct0hwvoo6Z',
      invoice: invoice,
      payment_method: payment_method,
      user: user
    )
  }
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
          "customer": "cus_LVeJwkMEn3BBnE",
          "description": "Payment for Invoice",
          "destination": nil,
          "dispute": nil,
          "disputed": false,
          "failure_balance_transaction": nil,
          "failure_code": nil,
          "failure_message": nil,
          "fraud_details": {
          },
          "invoice": "in_1LAk6PAWN1SYQ0CtCC1pSWvD",
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
          "payment_method": "pm_1Kod0ZAWN1SYQ0CtRiUcGEhe",
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
  let(:job) { Sync::Payment::Stripe::Inbound::UpdateJob }

  # before do
  #   allow_any_instance_of(Stripe::Charge).to receive(:status_transitions).and_return(double(paid_at: 1656976377))
  # end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(payment).not_to receive(:update!)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      [user, invoice, payment_method, payment].each(&:to_s)
      payment_object = object_double(Stripe::Event.construct_from(payload).data.object)
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      allow_any_instance_of(job).to receive(:webhook_event).and_return(webhook_event)
      params = job.new(webhook_event).params
      expect_any_instance_of(Payment).to receive(:update!).with({
        amount: 5000,
        description: "Payment for Invoice",
        paid: true,
        refunded: false,
        # statement_descriptor: nil,
        status: "succeeded",

        stripe_object: Stripe::Event.construct_from(payload).data.object.to_json,
        invoice: invoice,
        user: user,
        payment_method: payment_method
      })
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::Payment::Stripe::Inbound::UpdatePolicy)
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
      expect(job.new(webhook_event).stripe_object).to be_a(Stripe::Charge)
    end
  end

  describe "#params" do
    it "returns params" do
      [user, invoice, payment_method, payment].each(&:to_s)
      invoice_object = object_double(Stripe::Event.construct_from(payload).data.object)
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).params).to include(
        amount: 5000,
        description: "Payment for Invoice",
        paid: true,
        refunded: false,
        # statement_descriptor: nil,
        status: "succeeded",

        stripe_object: Stripe::Event.construct_from(payload).data.object.to_json,
        invoice: invoice,
        user: user,
        payment_method: payment_method
      )
    end
  end
end
