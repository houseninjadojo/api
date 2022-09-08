require 'rails_helper'

RSpec.describe EstimateResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'estimates',
          attributes: attributes_for(:estimate)
        }
      }
    end

    let(:instance) do
      EstimateResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Estimate.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:estimate) { create(:estimate) }

    let(:payload) do
      {
        data: {
          id: estimate.id.to_s,
          type: 'estimates',
          attributes: { } # Todo!
        }
      }
    end

    let(:instance) do
      EstimateResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { estimate.reload.updated_at }
      # .and change { estimate.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:estimate) { create(:estimate) }

    let(:instance) do
      EstimateResource.find(id: estimate.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Estimate.count }.by(-1)
    end
  end
end
