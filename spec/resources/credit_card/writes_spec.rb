require 'rails_helper'

RSpec.describe CreditCardResource, type: :resource do
  describe 'creating' do
    let(:user) { create(:user) }
    let(:payload) do
      {
        data: {
          type: 'credit-cards',
          attributes: attributes_for(:credit_card).without(:stripe_token),
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
      CreditCardResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { CreditCard.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:credit_card) { create(:credit_card) }

    let(:payload) do
      {
        data: {
          id: credit_card.id.to_s,
          type: 'credit-cards',
          attributes: {
            zipcode: '12345',
          }
        }
      }
    end

    let(:instance) do
      CreditCardResource.find(payload)
    end

    it 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { credit_card.reload.updated_at }
      .and change { credit_card.zipcode }.to('12345')
    end
  end

  describe 'destroying' do
    let!(:user) { create(:user) }
    let!(:credit_card) { create(:credit_card) }

    let(:instance) do
      CreditCardResource.find(id: credit_card.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { CreditCard.count }.by(-1)
    end
  end
end
