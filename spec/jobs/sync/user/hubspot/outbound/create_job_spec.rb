require 'rails_helper'

RSpec.describe Sync::User::Hubspot::Outbound::CreateJob, type: :job do
  let(:user) { create(:user) }

  let(:job) { Sync::User::Hubspot::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Contact).not_to receive(:create_or_update)
      job.perform_now(user)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user).params
      expect(Hubspot::Contact).to receive(:create_or_update).with(user.email, params).and_return(double(id: "contact_id"))
      job.perform_now(user)
      expect(user.hubspot_id).to eq("contact_id")
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Hubspot::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect(job.new(user).policy).to be_a(Sync::User::Hubspot::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Contact.create_or_update" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user).params).to eq(
        {
          contact_type:    user.contact_type,
          coupon_code:     user&.subscription&.promo_code&.code,
          house_ninja_id:  user.id,
          email:           user.email,
          firstname:       user.first_name,
          lastname:        user.last_name,
          phone:           user.phone_number,

          onboarding_code:  user.onboarding_code,
          onboarding_link:  user.onboarding_link,
          onboarding_step:  user.onboarding_step,
          onboarding_token: user.onboarding_token,

          personal_referral_code: user&.promo_code&.code,

          how_did_you_hear_about_us_: user.how_did_you_hear_about_us,
        }
      )
    end
  end
end
