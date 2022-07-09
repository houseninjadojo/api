require 'rails_helper'

RSpec.describe Sync::User::Intercom::Outbound::CreateJob, type: :job do
  let(:user) { create(:user) }

  let(:job) { Sync::User::Intercom::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Intercom::Service::Contact).to_not receive(:create)
      job.perform_now(user)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user).params
      expect_any_instance_of(Intercom::Service::Contact).to receive(:create).and_return(double(id: "1234"))
      job.perform_now(user)
      expect(user.intercom_id).to eq("1234")
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Intercom::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect(job.new(user).policy).to be_a(Sync::User::Intercom::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Intercom::Contact#create" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user).params).to eq({
        role: "user",
        name: user.full_name,
        email: user.email,
        phone: user.phone_number,
        external_id: user.id,
      })
    end
  end
end
