require 'rails_helper'

RSpec.describe PaymentMethodResource, type: :resource do
  describe 'creating' do
    let(:user) { create(:user) }
    let(:payload) do
      {
        data: {
          type: 'credit-cards',
          attributes: attributes_for(:credit_card),
          relationships: {
            user: {
              data: {
                type: 'users',
                id: user.id
              }
            }
          }
        }
      }
    end

    let(:instance) do
      PaymentMethodResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { PaymentMethod.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:payment_method) { create(:credit_card) }

    let(:payload) do
      {
        data: {
          id: payment_method.id.to_s,
          type: 'credit-cards',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      PaymentMethodResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { payment_method.reload.updated_at }
      # .and change { payment_method.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:payment_method) { create(:credit_card) }

    let(:instance) do
      CreditCardResource.find(id: payment_method.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { PaymentMethod.count }.by(-1)
    end
  end
end
