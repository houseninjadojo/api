require 'rails_helper'

RSpec.describe Sync::Property::Arrivy::OutboundJob, type: :job do
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
  let(:job) { Sync::Property::Arrivy::OutboundJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Arrivy::Customer).not_to receive(:update)
      job.perform_now(property, changeset)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property, changeset).params
      expect_any_instance_of(Arrivy::Customer).to receive(:save)
      expect(Arrivy::Customer).to receive(:find).and_return(
        Arrivy::Customer.new(id: "12345")
      )
      job.perform_now(property, changeset)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect_any_instance_of(job).to(receive(:changeset).at_least(:once).and_return(changeset))
      expect(job.new(property, changeset).policy).to be_a(Sync::Property::Arrivy::OutboundPolicy)
    end
  end

  describe "#params" do
    it "returns params for Arrivy::Customer#update" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property, changeset).params).to eq({
        address_line_1: property.street_address1,
        address_line_2: property.street_address2,
        city: property.city,
        state: property.state,
        zipcode: property.zipcode,
      })
    end
  end
end
