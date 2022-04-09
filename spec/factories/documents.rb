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
FactoryBot.define do
  factory :document do
    document_group
  end
end
