# == Schema Information
#
# Table name: documents
#
#  id                :uuid             not null, primary key
#  user_id           :uuid
#  invoice_id        :uuid
#  property_id       :uuid
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_group_id :uuid
#  name              :string
#  description       :string
#
# Indexes
#
#  index_documents_on_document_group_id  (document_group_id)
#  index_documents_on_invoice_id         (invoice_id)
#  index_documents_on_property_id        (property_id)
#  index_documents_on_user_id            (user_id)
#
require 'rails_helper'

RSpec.describe Document, type: :model do
  describe "#name" do
    it "returns the filename if no name is set" do
      document = build(:document, name: nil)
      expect(document.name).to eq(document.asset.filename.to_s)
    end

    it "returns the name if set" do
      document = build(:document, name: "My document")
      expect(document.name).to eq("My document")
    end
  end
end
