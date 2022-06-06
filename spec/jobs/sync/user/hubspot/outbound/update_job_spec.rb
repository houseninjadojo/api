require 'rails_helper'

RSpec.describe Sync::User::Hubspot::Outbound::UpdateJob, type: :job do
  let(:user) { create(:user) }
  let(:changed_attributes) {
    {
      "first_name": [user.first_name, "New First Name"],
      "updated_at": [user.updated_at, Time.zone.now],
    }
  }
  let(:job) { Sync::User::Hubspot::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Contact).not_to receive(:update!)
      job.perform_now(user, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changed_attributes).params
      expect(Hubspot::Contact).to receive(:update!).with(user.hubspot_id, params)
      job.perform_now(user, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Hubspot::Outbound::UpdatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(user, changed_attributes).policy).to be_a(Sync::User::Hubspot::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Contact.update!" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changed_attributes).params).to eq({
        contact_type: user.contact_type,
        email:        user.email,
        firstname:    user.first_name,
        lastname:     user.last_name,
        phone:        user.phone_number,
        zip:          user.requested_zipcode,

        onboarding_code: user.onboarding_code,
        onboarding_link: user.onboarding_link,
        onboarding_step: user.onboarding_step,
      }.compact)
    end
  end
end
