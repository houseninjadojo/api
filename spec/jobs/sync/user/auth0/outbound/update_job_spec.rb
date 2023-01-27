require 'rails_helper'

RSpec.describe Sync::User::Auth0::Outbound::UpdateJob, type: :job do
  let(:user) { create(:user, ) }
  let(:changeset) {
    [
      {
        path: [:first_name],
        old: user.first_name,
        new: 'new first name',
      }
    ]
  }
  let(:job) { Sync::User::Auth0::Outbound::UpdateJob }

  before(:each) do
    allow(AuthZero).to(receive(:client).and_return(double(patch_user: true, add_user_roles: true, remove_user_roles: true)))
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(AuthZero.client).not_to receive(:patch_user)
      expect(AuthZero.client).not_to receive(:add_user_roles)
      expect(AuthZero.client).not_to receive(:remove_user_roles)
      job.perform_now(user, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changeset).params
      expect(AuthZero.client).to receive(:patch_user).with(user.auth_id, params)
      expect(AuthZero.client).not_to receive(:add_user_roles)
      expect(AuthZero.client).to receive(:remove_user_roles)
      job.perform_now(user, changeset)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Auth0::Outbound::UpdatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(user, changeset).policy).to be_a(Sync::User::Auth0::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Auth0Client.patch_user" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changeset).params).to eq({
        email: user.email,
        name: user.full_name,
        given_name: user.first_name,
        family_name: user.last_name,
        connection: AuthZero.connection,
      })
    end
  end
end
