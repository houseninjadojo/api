require 'rails_helper'

RSpec.describe HomeCareTipResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'home-care-tips',
          attributes: attributes_for(:home_care_tip)
        }
      }
    end

    let(:instance) do
      HomeCareTipResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { HomeCareTip.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:home_care_tip) { create(:home_care_tip) }

    let(:payload) do
      {
        data: {
          id: home_care_tip.id.to_s,
          type: 'home-care-tips',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      HomeCareTipResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { home_care_tip.reload.updated_at }
      # .and change { home_care_tip.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:home_care_tip) { create(:home_care_tip) }

    let(:instance) do
      HomeCareTipResource.find(id: home_care_tip.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { HomeCareTip.count }.by(-1)
    end
  end
end
