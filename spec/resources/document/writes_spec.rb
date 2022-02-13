require 'rails_helper'

RSpec.describe DocumentResource, type: :resource do
  describe 'creating' do
    let(:payload) do
      {
        data: {
          type: 'documents',
          attributes: attributes_for(:document)
        }
      }
    end

    let(:instance) do
      DocumentResource.build(payload)
    end

    xit 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { Document.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:document) { create(:document) }

    let(:payload) do
      {
        data: {
          id: document.id.to_s,
          type: 'documents',
          attributes: {} # Todo!
        }
      }
    end

    let(:instance) do
      DocumentResource.find(payload)
    end

    xit 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { document.reload.updated_at }
      # .and change { document.foo }.to('bar') <- example
    end
  end

  describe 'destroying' do
    let!(:document) { create(:document) }

    let(:instance) do
      DocumentResource.find(id: document.id)
    end

    xit 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { Document.count }.by(-1)
    end
  end
end
