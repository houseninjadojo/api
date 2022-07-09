require 'rails_helper'

RSpec.describe Sync::User::Intercom::Outbound::UpdateJob, type: :job do
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
  let(:job) { Sync::User::Intercom::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Intercom::Service::Contact).to_not receive(:save)
      job.perform_now(user, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changeset).params
      expect_any_instance_of(Intercom::Service::Contact).to receive(:find).and_return(double(save: true))
      expect_any_instance_of(Intercom::Service::Contact).to receive(:save)
      job.perform_now(user, changeset)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Arrivy::Outbound::UpdatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(user, changeset).policy).to be_a(Sync::User::Intercom::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Auth0Client.patch_user" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changeset).params).to eq({
        role: "user",
        name: user.full_name,
        email: user.email,
        phone: user.phone_number,
        external_id: user.id,
      })
    end
  end
end
