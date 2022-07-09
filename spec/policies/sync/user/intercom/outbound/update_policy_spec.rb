require "rails_helper"

RSpec.describe Sync::User::Arrivy::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { create(:user) }

  let(:policy) { described_class.new(user) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:should_sync?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:should_sync?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    before(:each) do
      expect(policy).to receive(:has_external_id?).and_call_original
    end

    xit "returns true if user has intercom_id" do
      user.intercom_id = "1234"
      expect(policy.has_external_id?).to be_truthy
    end

    xit "returns false if user does not intercom_id" do
      user.intercom_id = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :should_sync? do
    it "returns true if user is subscribed" do
      expect(user).to receive(:subscription).and_return(double(active?: true)).at_least(:once)
      expect(policy.should_sync?).to be_truthy
    end

    it "returns false if user is not subscribed" do
      expect(user).to receive(:subscription).and_return(nil)
      expect(policy.should_sync?).to be_falsey
    end
  end
end
