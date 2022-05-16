require 'rails_helper'

RSpec.describe PaymentResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'payments',
          attributes: attributes_for(:payment)
        }
      }
    end

    let(:instance) do
      PaymentResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Payment.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:payment) { create(:payment) }

    let(:payload) do
      {
        data: {
          id: payment.id.to_s,
          type: 'payments',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      PaymentResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { payment.reload.updated_at }
      # .and change { payment.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:payment) { create(:payment) }

    let(:instance) do
      PaymentResource.find(id: payment.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Payment.count }.by(-1)
    end
  end
end
