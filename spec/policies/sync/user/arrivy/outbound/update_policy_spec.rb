require "rails_helper"

RSpec.describe Sync::User::Arrivy::Outbound::UpdatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { create(:user) }
  let(:changeset) {
    [
      {
        path: [:first_name],
        old: user.first_name,
        new: 'new first name',
      }
    ]
  }
  let(:policy) { described_class.new(user, changeset: changeset) }

  describe_rule :can_sync? do
    it "returns true if all conditions true" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions false" do
      expect(policy).to receive(:has_external_id?).and_return(true)
      expect(policy).to receive(:has_changed_attributes?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has auth id" do
      user.arrivy_id = "asdf"
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if user does not have stripe customer id" do
      user.arrivy_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_changed_attributes? do
    it "returns true if user has changed attributes" do
      user.update(first_name: "New First Name")
      policy = described_class.new(user, changeset: changeset)
      expect(policy.has_changed_attributes?).to be_truthy
    end

    it "returns false if user does not have changed attributes" do
      user.update(first_name: user.first_name) # no-op
      policy = described_class.new(user, changeset: [])
      expect(policy.has_changed_attributes?).to be_falsey
    end
  end
end
