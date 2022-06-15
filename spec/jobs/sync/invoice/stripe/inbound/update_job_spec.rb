require 'rails_helper'

RSpec.describe Sync::Invoice::Stripe::Inbound::UpdateJob, type: :job do
  let(:user) { create(:user, stripe_id: "cus_LVeJwkMEn3BBnE") }
  let(:subscription) { create(:subscription, stripe_id: "sub_1Kod0ZAWN1SYQ0CtRiUcGEhe") }
  # let(:payment) { create(:payment, stripe_id: "ch_1Kod0ZAWN1SYQ0CtRiUcGEhe") }
  let(:promo_code) { create(:promo_code, coupon_id: "coupon_1Kod0ZAWN1SYQ0CtRiUcGEhe") }
  let(:payload) {
    {
      "id"=>"evt_1LAl7oAWN1SYQ0Ct06CqCvvZ",
      "object"=>"event",
      "api_version"=>"2020-08-27",
      "created"=>1655256868,
      "data" => {
        "object" => {
          "id"=>"in_1LAk6PAWN1SYQ0CtCC1pSWvD",
          "object"=>"invoice",
          "account_country"=>"US",
          "account_name"=>"House Ninja Inc.",
          "account_tax_ids"=>nil,
          "amount_due"=>2900,
          "amount_paid"=>2900,
          "amount_remaining"=>0,
          "application"=>"ca_51GJLqjOuEAh1hmpox27im1DmgDRRzDp",
          "application_fee_amount"=>58,
          "attempt_count"=>1,
          "attempted"=>true,
          "auto_advance"=>false,
          "automatic_tax"=>{ "enabled"=>false, "status"=>nil },
          "billing_reason"=>"subscription_cycle",
          "charge"=>"ch_3LAl7lAWN1SYQ0Ct3iXGfWse",
          "collection_method"=>"charge_automatically",
          "created"=>1655252937,
          "currency"=>"usd",
          "custom_fields"=>nil,
          "customer"=>"cus_LVeJwkMEn3BBnE",
          "customer_address"=>nil,
          "customer_email"=>"cbrittward@gmail.com",
          "customer_name"=>"Britt Ward",
          "customer_phone"=>nil,
          "customer_shipping"=>nil,
          "customer_tax_exempt"=>"none",
          "customer_tax_ids"=>[],
          "default_payment_method"=>nil,
          "default_source"=>nil,
          "default_tax_rates"=>[],
          "description"=>"description here",
          "discount"=>nil,
          "discounts"=>[
            "di_1LAoKMAWN1SYQ0CtVHdQYh1J",
          ],
          "due_date"=>nil,
          "ending_balance"=>0,
          "footer"=>nil,
          "hosted_invoice_url"=>"https://invoice.stripe.com/i/acct_1IH0d5AWN1SYQ0Ct/live_YWNjdF8xSUgwZDVBV04xU1lRMEN0LF9Mc1Y2aFVXVEViR3RHako2cUptTXA3SWd5SkRMZjJvLDQ1Nzk3NjY40200J0YSSBCP?s=ap",
          "invoice_pdf"=>"https://pay.stripe.com/invoice/acct_1IH0d5AWN1SYQ0Ct/live_YWNjdF8xSUgwZDVBV04xU1lRMEN0LF9Mc1Y2aFVXVEViR3RHako2cUptTXA3SWd5SkRMZjJvLDQ1Nzk3NjY40200J0YSSBCP/pdf?s=ap",
          "last_finalization_error"=>nil,
          "lines" => {
            "object"=>"list",
            "data" => [
              {
                "id"=>"il_1LAk6PAWN1SYQ0CthSfEOIuq",
                "object"=>"line_item",
                "amount"=>2900,
                "amount_excluding_tax"=>2900,
                "currency"=>"usd",
                "description"=>"1 × House Ninja Monthly Recurring Subscription (at $29.00 / month)",
                "discount_amounts"=>[],
                "discountable"=>true,
                "discounts"=>[],
                "livemode"=>true,
                "metadata"=>{ "plan_id"=>"5074", "company_id"=>"2738", "company_name"=>"House Ninja", "customer_email"=>"cbrittward@gmail.com", "customer_name"=>"Britt Ward", "subscription_id"=>"26105" },
                "period"=>{ "end"=>1657844851, "start"=>1655252851 },
                "plan" => {
                  "id"=>"price_1Ie6wdAWN1SYQ0CtKiaqMHcA",
                  "object"=>"plan",
                  "active"=>true,
                  "aggregate_usage"=>nil,
                  "amount"=>2900,
                  "amount_decimal"=>"2900",
                  "billing_scheme"=>"per_unit",
                  "created"=>1617923247,
                  "currency"=>"usd",
                  "interval"=>"month",
                  "interval_count"=>1,
                  "livemode"=>true,
                  "metadata"=>{},
                  "nickname"=>nil,
                  "product"=>"prod_J1eBMo47WiDtcH",
                  "tiers_mode"=>nil,
                  "transform_usage"=>nil,
                  "trial_period_days"=>nil,
                  "usage_type"=>"licensed"
                },
                "price" => {
                  "id"=>"price_1Ie6wdAWN1SYQ0CtKiaqMHcA",
                  "object"=>"price",
                  "active"=>true,
                  "billing_scheme"=>"per_unit",
                  "created"=>1617923247,
                  "currency"=>"usd",
                  "custom_unit_amount"=>nil,
                  "livemode"=>true,
                  "lookup_key"=>"[FILTERED]",
                  "metadata"=>{},
                  "nickname"=>nil,
                  "product"=>"prod_J1eBMo47WiDtcH",
                  "recurring"=>{ "aggregate_usage"=>nil, "interval"=>"month", "interval_count"=>1, "trial_period_days"=>nil, "usage_type"=>"licensed" },
                  "tax_behavior"=>"unspecified",
                  "tiers_mode"=>nil,
                  "transform_quantity"=>nil,
                  "type"=>"recurring",
                  "unit_amount"=>2900,
                  "unit_amount_decimal"=>"2900"
                },
                "proration"=>false,
                "proration_details"=>{ "credited_items"=>nil },
                "quantity"=>1,
                "subscription"=>"sub_1Kod0ZAWN1SYQ0CtRiUcGEhe",
                "subscription_item"=>"si_LVeJ3Q2Q4cC36F",
                "tax_amounts"=>[],
                "tax_rates"=>[],
                "type"=>"subscription",
                "unit_amount_excluding_tax"=>"2900"
              }
            ],
            "has_more"=>false,
            "total_count"=>1,
            "url"=>"/v1/invoices/in_1LAk6PAWN1SYQ0CtCC1pSWvD/lines"
          },
          "livemode"=>true,
          "metadata"=>{},
          "next_payment_attempt"=>nil,
          "number"=>"8FEE577D-0003",
          "on_behalf_of"=>nil,
          "paid"=>true,
          "paid_out_of_band"=>false,
          "payment_intent"=>"pi_3LAl7lAWN1SYQ0Ct3jzaFJ5S",
          "payment_settings"=>{ "payment_method_options"=>nil, "payment_method_types"=>nil },
          "period_end"=>1655252851,
          "period_start"=>1652574451,
          "post_payment_credit_notes_amount"=>0,
          "pre_payment_credit_notes_amount"=>0,
          "quote"=>nil,
          "receipt_number"=>nil,
          "rendering_options"=>nil,
          "starting_balance"=>0,
          "statement_descriptor"=>nil,
          "status"=>"paid",
          "status_transitions"=>{ "finalized_at"=>1655256864, "marked_uncollectible_at"=>nil, "paid_at"=>1655256864, "voided_at"=>nil },
          "subscription"=>"sub_1Kod0ZAWN1SYQ0CtRiUcGEhe",
          "subtotal"=>2900,
          "subtotal_excluding_tax"=>2900,
          "tax"=>nil,
          "test_clock"=>nil,
          "total"=>2900,
          "total_discount_amounts"=>[],
          "total_excluding_tax"=>2900,
          "total_tax_amounts"=>[],
          "transfer_data"=>nil,
          "webhooks_delivered_at"=>1655252938
        },
        "previous_attributes" => {
          "amount_paid"=>0,
          "amount_remaining"=>2900,
          "application_fee_amount"=>nil,
          "attempt_count"=>0,
          "attempted"=>false,
          "auto_advance"=>true,
          "charge"=>nil,
          "ending_balance"=>nil,
          "hosted_invoice_url"=>nil,
          "invoice_pdf"=>nil,
          "next_payment_attempt"=>1655256537,
          "number"=>nil,
          "paid"=>false,
          "payment_intent"=>nil,
          "status"=>"draft",
          "status_transitions"=>{ "finalized_at"=>nil, "paid_at"=>nil }
        }
      },
      "livemode"=>true,
      "pending_webhooks"=>1,
      "request"=>{ "id"=>nil, "idempotency_key"=>"[FILTERED]" },
      "type"=>"invoice.updated"
    }.with_indifferent_access
  }
  let(:discount) {
    {
      "id": "di_1LAoKMAWN1SYQ0CtVHdQYh1J",
      "object": "discount",
      "checkout_session": nil,
      "coupon": {
        "id": "coupon_1Kod0ZAWN1SYQ0CtRiUcGEhe",
        "object": "coupon",
        "amount_off": nil,
        "created": 1655269163,
        "currency": nil,
        "duration": "forever",
        "duration_in_months": nil,
        "livemode": false,
        "max_redemptions": nil,
        "metadata": {},
        "name": "invoice test coupon",
        "percent_off": 50.0,
        "redeem_by": nil,
        "times_redeemed": 1,
        "valid": nil
      },
      "customer": "cus_L7l9igIW7ntedG",
      "end": nil,
      "invoice": "in_1LAoJTAWN1SYQ0Ct5gdCBKvd",
      "invoice_item": nil,
      "promotion_code": promo_code.code,
      "start": 1655269178,
      "subscription": nil
    }
  }
  let(:webhook_event) {
    create(:webhook_event,
      service: 'stripe',
      payload: payload
    )
  }
  let(:invoice) {
    create(:invoice,
      stripe_id: 'in_1LAk6PAWN1SYQ0CtCC1pSWvD',
      total: 2900,
      user: user
    )
  }
  let(:job) { Sync::Invoice::Stripe::Inbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(invoice).not_to receive(:update!)
      job.perform_now(webhook_event)
    end

    it "will sync if policy approves" do
      [invoice, user, subscription, promo_code].each(&:to_s)
      invoice_object = object_double(Stripe::Event.construct_from(payload).data.object)
      allow(invoice_object).to receive(:discounts).and_return([Stripe::Discount.construct_from(discount)])
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      allow_any_instance_of(job).to receive(:webhook_event).and_return(webhook_event)
      allow(Stripe::Invoice).to receive(:retrieve).and_return(invoice_object)
      params = job.new(webhook_event).params
      expect_any_instance_of(Invoice).to receive(:update!).with({
        description: "description here",
        period_end: Time.at(1655252851),
        period_start: Time.at(1652574451),
        status: "paid",
        total: 2900,
        stripe_object: Stripe::Event.construct_from(payload).data.object.to_json,
        subscription: subscription,
        user: user,
        promo_code: promo_code
      })
      expect(webhook_event).to receive(:update!)
      job.perform_now(webhook_event)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      expect(job.new(webhook_event).policy).to be_a(Sync::Invoice::Stripe::Inbound::UpdatePolicy)
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
      expect(job.new(webhook_event).stripe_object).to be_a(Stripe::Invoice)
    end
  end

  describe "#params" do
    it "returns params" do
      [user, subscription, promo_code].each(&:to_s)
      invoice_object = object_double(Stripe::Event.construct_from(payload).data.object)
      allow(invoice_object).to receive(:discounts).and_return([Stripe::Discount.construct_from(discount)])
      expect_any_instance_of(job).to(receive(:webhook_event).at_least(:once).and_return(webhook_event))
      allow(Stripe::Invoice).to receive(:retrieve).and_return(invoice_object)
      expect(job.new(webhook_event).params).to include(
        description: "description here",
        period_end: Time.at(1655252851),
        period_start: Time.at(1652574451),
        status: "paid",
        total: 2900,

        user: user,
        subscription: subscription,
        # payment: payment,
        promo_code: promo_code,

        stripe_object: Stripe::Event.construct_from(payload).data.object.to_json,
      )
    end
  end
end
