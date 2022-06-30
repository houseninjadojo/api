require 'rails_helper'

RSpec.describe Sync::User::Hubspot::Outbound::UpdateJob, type: :job do
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
  let(:job) { Sync::User::Hubspot::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Contact).not_to receive(:update!)
      job.perform_now(user, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(user, changeset).params
      expect(Hubspot::Contact).to receive(:update!).with(user.hubspot_id, params)
      job.perform_now(user, changeset)
    end
  end

  describe "#policy" do
    it "returns a Sync::User::Hubspot::Outbound::UpdatePolicy" do
      expect_any_instance_of(job).to(receive(:user).at_least(:once).and_return(user))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(user, changeset).policy).to be_a(Sync::User::Hubspot::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Contact.update!" do
      allow_any_instance_of(job).to(receive(:user).and_return(user))
      expect(job.new(user, changeset).params).to eq({
        email:         user.email,
        firstname:     user.first_name,
        lastname:      user.last_name,
        phone:         user.phone_number,
        zip:           user.requested_zipcode,

        onboarding_code:  user.onboarding_code,
        onboarding_link:  user.onboarding_link,
        onboarding_step:  user.onboarding_step,
        onboarding_token: user.onboarding_token,

        contact_type:  user.contact_type,
        customer_type: user.customer_type,

        'promo_code_used_': user&.subscription&.promo_code&.code,

        personal_referral_code: user&.promo_code&.code,
      }.compact)
    end
  end
end
