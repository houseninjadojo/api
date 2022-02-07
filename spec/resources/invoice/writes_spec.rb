require 'rails_helper'

RSpec.describe InvoiceResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'invoices',
          attributes: attributes_for(:invoice)
        }
      }
    end

    let(:instance) do
      InvoiceResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Invoice.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:invoice) { create(:invoice) }

    let(:payload) do
      {
        data: {
          id: invoice.id.to_s,
          type: 'invoices',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      InvoiceResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { invoice.reload.updated_at }
      # .and change { invoice.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:invoice) { create(:invoice) }

    let(:instance) do
      InvoiceResource.find(id: invoice.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Invoice.count }.by(-1)
    end
  end
end
