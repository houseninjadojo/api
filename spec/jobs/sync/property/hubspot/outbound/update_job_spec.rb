require 'rails_helper'

RSpec.describe Sync::Property::Hubspot::Outbound::UpdateJob, type: :job do
  let(:property) { create(:property) }
  let(:changeset) {
    [
      {
        path: [:street_address1],
        old: property.street_address1,
        new: 'new street address',
      }
    ]
  }
  let(:job) { Sync::Property::Hubspot::Outbound::UpdateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Hubspot::Contact).not_to receive(:update!)
      job.perform_now(property, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property, changeset).params
      expect(Hubspot::Contact).to receive(:update!).with(property.user.hubspot_id, params)
      job.perform_now(property, changeset)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(property, changeset).policy).to be_a(Sync::Property::Hubspot::Outbound::UpdatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Hubspot::Contact#update!" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property, changeset).params).to eq({
        address: property.street_address1,
        address_2: property.street_address2,
        city: property.city,
        state_new:  StateNames.abbreviations[property.state],
        zip: property.zipcode,
      })
    end
  end
end
