require 'rails_helper'

RSpec.describe Sync::Property::Arrivy::Outbound::CreateJob, type: :job do
  let(:property) { create(:property) }

  let(:job) { Sync::Property::Arrivy::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect_any_instance_of(Arrivy::Customer).not_to receive(:create)
      job.perform_now(property)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property).params
      # expect(RestClient::Request).to receive(:execute)
      expect_any_instance_of(Arrivy::Customer).to receive(:save).and_return(double(id: "1234"))
      expect(Arrivy::Customer).to receive(:find).and_return(
        Arrivy::Customer.new(id: "12345")
      )
      job.perform_now(property)
      # expect(property.user.arrivy_id).to eq("1234")
    end
  end

  describe "#policy" do
    it "returns a Sync::Property::Arrivy::Outbound::CreatePolicy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect(job.new(property).policy).to be_a(Sync::Property::Arrivy::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Arrivy::Customer#create" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property).params).to eq({
        address_line_1: property.street_address1,
        address_line_2: property.street_address2,
        city: property.city,
        state: property.state,
        zipcode: property.zipcode,
      })
    end
  end
end
