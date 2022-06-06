require "rails_helper"

RSpec.describe Sync::User::Auth0::Outbound::CreatePolicy, type: :policy do
  # See https://actionpolicy.evilmartians.io/#/testing?id=rspec-dsl
  #
  let(:user) { create(:user) }

  let(:policy) { described_class.new(user) }

  describe_rule :can_sync? do
    it "returns true if all conditions match" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_password?).and_return(true)
      expect(policy.can_sync?).to be_truthy
    end

    it "returns false if any conditions fail" do
      expect(policy).to receive(:has_external_id?).and_return(false)
      expect(policy).to receive(:has_password?).and_return(false)
      expect(policy.can_sync?).to be_falsey
    end
  end

  describe_rule :has_external_id? do
    it "returns true if user has auth0 id" do
      user.auth_zero_user_created = true
      expect(policy.has_external_id?).to be_truthy
    end

    it "returns false if user does not auth0 id" do
      user.auth_zero_user_created = nil
      expect(policy.has_external_id?).to be_falsey
    end
  end

  describe_rule :has_password? do
    it "returns true if user has password" do
      user.password = "password"
      expect(policy.has_password?).to be_truthy
    end

    it "returns false if user does not have password" do
      user.password = nil
      expect(policy.has_password?).to be_falsey
    end
  end
end
