require 'rails_helper'

RSpec.describe Sync::Property::Stripe::OutboundJob, type: :job do
  let(:property) { create(:property) }
  let(:changed_attributes) {
    {
      "street_address1": [property.street_address1, "New Street Address 1"],
      "updated_at": [property.updated_at, Time.zone.now],
    }
  }
  let(:job) { Sync::Property::Stripe::OutboundJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Customer).not_to receive(:update)
      job.perform_now(property, changed_attributes)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property, changed_attributes).params
      expect(Stripe::Customer).to receive(:update).with(property.user.stripe_customer_id, params)
      job.perform_now(property, changed_attributes)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect_any_instance_of(job).to(receive(:changed_attributes).at_least(:once).and_return(changed_attributes))
      expect(job.new(property, changed_attributes).policy).to be_a(Sync::Property::Stripe::OutboundPolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Customer#update" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property, changed_attributes).params).to eq({
        address: {
          line1: property.street_address1,
          line2: property.street_address2,
          city: property.city,
          state: property.state,
          postal_code: property.zipcode,
        }
      })
    end
  end
end
