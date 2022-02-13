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
class Document < ApplicationRecord
  # callbacks

  # associations

  belongs_to :invoice,  required: false
  belongs_to :property, required: false
  belongs_to :user,     required: false

  # storage

  has_one_attached :asset

  # helpers

  def content_type
    asset.try(:content_type)
  end

  def filename
    asset.try(:filename).try(:to_s)
  end

  def filename=(val)
    asset.present? && asset.blob.update!(filename: val)
  end

  def url
    asset.try(:url)
  end
end
