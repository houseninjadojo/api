require "rails_helper"

RSpec.describe Sync::Invoice::Stripe::Outbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:invoice) { create(:invoice) }
  let(:changeset) {
    [
      {
        path: [:description],
        old: invoice.description,
        new: 'new description',
      }
    ]
  }
  let(:policy) { described_class.new(invoice, changeset: changeset) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      # expect(policy).to receive(:is_actionable?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(false)
      # expect(policy).to receive(:is_actionable?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if invoice has stripe customer id" do
      invoice.stripe_id = "cus_123"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if invoice does not have stripe customer id" do
      invoice.stripe_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if invoice has changed attributes" do
      # expect(SyncChangeset).to(receive(:changeset).with(
      #   record: invoice,
      #   action: :update,
      #   service: :stripe,
      # ).at_least(:once).and_call_original)
      invoice.update(description: "new description")
      policy = described_class.new(invoice, changeset: changeset)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if invoice does not have changed attributes" do
      invoice.update(description: "new description") # no-op
      policy = described_class.new(invoice, changeset: [])
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
