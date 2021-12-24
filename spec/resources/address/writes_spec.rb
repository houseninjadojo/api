require 'rails_helper'

RSpec.describe AddressResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'addresses',
          attributes: attributes_for(:address)
        }
      }
    end

    let(:instance) do
      AddressResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Address.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:address) { create(:address) }

    let(:payload) do
      {
        data: {
          id: address.id.to_s,
          type: 'addresses',
          attributes: { } # Todo!
        }
      }
    end

    let(:instance) do
      AddressResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { address.reload.updated_at }
      # .and change { address.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:address) { create(:address) }

    let(:instance) do
      AddressResource.find(id: address.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Address.count }.by(-1)
    end
  end
end
