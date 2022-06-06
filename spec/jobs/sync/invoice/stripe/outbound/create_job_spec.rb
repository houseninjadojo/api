require 'rails_helper'

RSpec.describe Sync::Invoice::Stripe::Outbound::CreateJob, type: :job do
  let(:payment_method) { build(:credit_card) }
  let(:subscription) { build(:subscription) }
  let(:user) { build(:user) }
  let(:resource) { build(:invoice, user: user, subscription: subscription) }

  let(:job) { Sync::Invoice::Stripe::Outbound::CreateJob }

  before(:each) do
    user.payment_methods << payment_method
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::InvoiceItem).not_to receive(:create)
      expect(Stripe::Invoice).not_to receive(:create)
      job.perform_now(resource)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      job_instance = job.new(resource)
      expect(Stripe::InvoiceItem).to receive(:create).with(job_instance.line_item_params)
      expect(Stripe::Invoice).to receive(:create).with(job_instance.params).and_return(double(id: "stripe_token",))
      job.perform_now(resource)
      expect(resource.stripe_id).to eq("stripe_token")
    end
  end

  describe "#policy" do
    it "returns a Sync::Invoice::Stripe::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:resource).at_least(:once).and_return(resource))
      expect(job.new(resource).policy).to be_a(Sync::Invoice::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Invoice.create" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).params).to include(
        {
          auto_advance:           false,
          collection_method:      "charge_automatically",
          customer:               resource.user.stripe_id,
          default_payment_method: resource.user.default_payment_method.stripe_id,
          description:            resource.description,
          subscription:           resource.subscription.stripe_id,
        }
      )
    end
  end

  describe "#line_item_params" do
    it "returns params for Stripe::InvoiceItem.create" do
      allow_any_instance_of(job).to(receive(:resource).and_return(resource))
      expect(job.new(resource).line_item_params).to include(
        {
          amount:   resource.total,
          currency: 'usd',
          customer: resource.user.stripe_id,
        }
      )
    end
  end
end
