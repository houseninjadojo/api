# == Schema Information
#
# Table name: documents
#
#  id          :uuid             not null, primary key
#  user_id     :uuid
#  invoice_id  :uuid
#  property_id :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_documents_on_invoice_id   (invoice_id)
#  index_documents_on_property_id  (property_id)
#  index_documents_on_user_id      (user_id)
#
FactoryBot.define do
  factory :document do

  end
end
