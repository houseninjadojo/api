require 'rails_helper'

RSpec.describe Sync::User::Arrivy::Outbound::CreateJob, type: :job do
  let(:user) { create(:user) }

  let(:job) { Sync::User::Arrivy::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Arrivy::Customer).not_to receive(:create)
      job.perform_now(user)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user).params
      expect_any_instance_of(Arrivy::Customer).to receive(:create).and_return(double(id: "1234"))
      job.perform_now(user)
      expect(user.arrivy_id).to eq("1234")
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Arrivy::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect(job.new(user).policy).to be_a(Sync::User::Arrivy::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Arrivy::Customer#create" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user).params).to eq({
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
