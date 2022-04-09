require 'rails_helper'

RSpec.describe DocumentGroupResource, type: :resource do
  describe 'creating' do
    let(:user) { create(:user) }
    let(:payload) do
      {
        data: {
          type: 'document-groups',
          attributes: attributes_for(:document_group),
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
      DocumentGroupResource.build(payload)
    end

    it 'works' do
      expect {
        expect(instance.save).to eq(true), instance.errors.full_messages.to_sentence
      }.to change { DocumentGroup.count }.by(1)
    end
  end

  describe 'updating' do
    let!(:document_group) { create(:document_group) }

    let(:payload) do
      {
        data: {
          id: document_group.id.to_s,
          type: 'document-groups',
          attributes: {
            name: 'Updated'
          }
        }
      }
    end

    let(:instance) do
      DocumentGroupResource.find(payload)
    end

    it 'works (add some attributes and enable this spec)' do
      expect {
        expect(instance.update_attributes).to eq(true)
      }.to change { document_group.reload.updated_at }
      .and change { document_group.name }.to('Updated')
    end
  end

  describe 'destroying' do
    let!(:document_group) { create(:document_group) }

    let(:instance) do
      DocumentGroupResource.find(id: document_group.id)
    end

    it 'works' do
      expect {
        expect(instance.destroy).to eq(true)
      }.to change { DocumentGroup.count }.by(-1)
    end
  end
end
