require 'rails_helper'

RSpec.describe Sync::Property::Stripe::Outbound::UpdateJob, type: :job do
  let(:property) { create(:property) }
  let(:changeset) {
    [
      {
        path: [:street_address1],
        old: property.street_address1,
        new: 'new street address 1',
      }
    ]
  }
  let(:job) { Sync::Property::Stripe::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Customer).not_to receive(:update)
      job.perform_now(property, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property, changeset).params
      expect(Stripe::Customer).to receive(:update).with(property.user.stripe_id, params)
      job.perform_now(property, changeset)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(property, changeset).policy).to be_a(Sync::Property::Stripe::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Customer#update" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property, changeset).params).to eq({
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
