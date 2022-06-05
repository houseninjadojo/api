require 'rails_helper'

RSpec.describe Sync::User::Arrivy::OutboundJob, type: :job do
  let(:user) { create(:user) }
  let(:changed_attributes) {
    {
      "first_name": [user.first_name, "New First Name"],
      "updated_at": [user.updated_at, Time.zone.now],
    }
  }
  let(:job) { Sync::User::Arrivy::OutboundJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Arrivy::Customer).not_to receive(:update)
      job.perform_now(user, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changed_attributes).params
      expect_any_instance_of(Arrivy::Customer).to receive(:update)
      job.perform_now(user, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Arrivy::OutboundPolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(user, changed_attributes).policy).to be_a(Sync::User::Arrivy::OutboundPolicy)
    end
  end

  describe "#params" do
    it "returns params for Auth0Client.patch_user" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changed_attributes).params).to eq({
        id: user.arrivy_id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        phone: user.phone_number,
        mobile_number: user.phone_number,
        external_id: user.id,
      })
    end
  end
end
