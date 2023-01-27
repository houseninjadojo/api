require 'rails_helper'

RSpec.describe Sync::User::Auth0::Outbound::CreateJob, type: :job do
  let(:user) { create(:user) }

  let(:job) { Sync::User::Auth0::Outbound::CreateJob }

  before(:each) do
    allow(AuthZero).to(receive(:client).and_return(double(create_user: true, add_user_roles: true)))
  end

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(AuthZero.client).not_to receive(:create_user)
      expect(AuthZero.client).not_to receive(:add_user_roles)
      job.perform_now(user)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user).params
      expect(AuthZero.client).to receive(:create_user).with(AuthZero.connection, params)
      expect(AuthZero.client).to receive(:add_user_roles).with(/auth0\|[a-zA-Z0-9\-]+/, AuthZero::Params.roles_for_unsubscribed)
      job.perform_now(user)
      expect(user.auth_zero_user_created).to be_truthy
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Auth0::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect(job.new(user).policy).to be_a(Sync::User::Auth0::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for AuthZero.client.create_user" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user).params).to eq(
        AuthZero::Params.for_create_user(user)
      )
    end
  end
end
