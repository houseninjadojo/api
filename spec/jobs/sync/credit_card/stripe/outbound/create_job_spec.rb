require 'rails_helper'

RSpec.describe Sync::CreditCard::Stripe::Outbound::CreateJob, type: :job do
  let(:resource) { create(:payment_method) }

  let(:job) { Sync::CreditCard::Stripe::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::PaymentMethod).not_to receive(:create)
      job.perform_now(resource)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(resource).params
      expect(Stripe::PaymentMethod).to receive(:create).with(params, { proxy: nil }).and_return(double(id: "stripe_token"))
      expect(Stripe::PaymentMethod).to receive(:attach).with("stripe_token", { customer: resource.user.stripe_id })
      job.perform_now(resource)
      expect(resource.stripe_id).to eq("stripe_token")
    end
  end

  describe "#policy" do
    it "returns a Sync::CreditCard::Stripe::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::CreditCard::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::PaymentMethod.create" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).params).to include(
        {
          type: 'card',
          card: {
            number: resource.card_number,
            exp_month: resource.exp_month,
            exp_year: resource.exp_year,
            cvc: resource.cvv,
          }
        }
      )
    end
  end
end
