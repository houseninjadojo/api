require 'rails_helper'

RSpec.describe Sync::Property::Stripe::Outbound::CreateJob, type: :job do
  let(:property) { create(:property) }

  let(:job) { Sync::Property::Stripe::Outbound::CreateJob }

  describe "#perform" do
    it "will not sync if policy declines" do
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: false))
      expect(Stripe::Customer).not_to receive(:update)
      job.perform_now(property)
    end

    it "will sync if policy approves" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      allow_any_instance_of(job).to receive(:policy).and_return(double(can_sync?: true))
      params = job.new(property).params
      expect(Stripe::Customer).to receive(:update).with(property.user.stripe_id, params)
      job.perform_now(property)
    end
  end

  describe "#policy" do
    it "returns a policy" do
      expect_any_instance_of(job).to(receive(:property).at_least(:once).and_return(property))
      expect(job.new(property).policy).to be_a(Sync::Property::Stripe::Outbound::CreatePolicy)
    end
  end

  describe "#params" do
    it "returns params for Stripe::Customer#update" do
      allow_any_instance_of(job).to(receive(:property).and_return(property))
      expect(job.new(property).params).to eq({
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
