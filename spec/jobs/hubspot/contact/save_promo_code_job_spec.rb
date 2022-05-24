require 'rails_helper'

RSpec.describe Hubspot::Contact::SavePromoCodeJob, type: :job do
  describe "#perform_*" do
    let(:user) { create(:user, hubspot_id: '1234') }
    let(:promo_code) { create(:promo_code) }
    let(:subscription) { create(:subscription, user: user, promo_code: promo_code) }
    let(:job) { Hubspot::Contact::SavePromoCodeJob }

    it "calls Hubspot::Contact.update!" do
      expect(Hubspot::Contact).to receive(:update!).with(user.hubspot_id, {
        'promo_code_used_': promo_code.code,
      })
      job.perform_now(user, promo_code)
    end
  end
end
