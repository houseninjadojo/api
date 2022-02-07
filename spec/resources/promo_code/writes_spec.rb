require 'rails_helper'

RSpec.describe PromoCodeResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'promo-codes',
          attributes: attributes_for(:promo_code)
        }
      }
    end

    let(:instance) do
      PromoCodeResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { PromoCode.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:promo_code) { create(:promo_code) }

    let(:payload) do
      {
        data: {
          id: promo_code.id.to_s,
          type: 'promo-codes',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      PromoCodeResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { promo_code.reload.updated_at }
      # .and change { promo_code.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:promo_code) { create(:promo_code) }

    let(:instance) do
      PromoCodeResource.find(id: promo_code.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { PromoCode.count }.by(-1)
    end
  end
end
