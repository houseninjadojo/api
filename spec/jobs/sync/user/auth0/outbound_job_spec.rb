require 'rails_helper'

RSpec.describe Sync::User::Auth0::OutboundJob, type: :job do
  let(:user) { create(:user) }
  let(:changed_attributes) {
    {
      "first_name": [user.first_name, "New First Name"],
      "updated_at": [user.updated_at, Time.zone.now],
    }
  }
  let(:job) { Sync::User::Auth0::OutboundJob }

  before(:each) do
    allow(AuthZero).to(receive(:client).and_return(double(patch_user: true)))
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(AuthZero.client).not_to receive(:patch_user)
      job.perform_now(user, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changed_attributes).params
      expect(AuthZero.client).to receive(:patch_user).with(user.auth_id, params)
      job.perform_now(user, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Auth0::OutboundPolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(user, changed_attributes).policy).to be_a(Sync::User::Auth0::OutboundPolicy)
    end
  end

  describe "#params" do
    it "returns params for Auth0Client.patch_user" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changed_attributes).params).to eq({
        email: user.email,
        name: user.full_name,
        given_name: user.first_name,
        family_name: user.last_name,
        connection: AuthZero.connection,
      })
    end
  end
end
