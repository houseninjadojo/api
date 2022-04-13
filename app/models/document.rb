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
#  tags              :text             default([]), not null, is an Array
#
# Indexes
#
#  index_documents_on_document_group_id  (document_group_id)
#  index_documents_on_invoice_id         (invoice_id)
#  index_documents_on_property_id        (property_id)
#  index_documents_on_tags               (tags) USING gin
#  index_documents_on_user_id            (user_id)
#
class Document < ApplicationRecord
  module SystemTags
    PMP = 'system:preventative-maintenance-plan'
    WALKTHROUGH_REPORT = 'system:walkthrough-report'
  end

  # callbacks

  # associations

  belongs_to :document_group, required: false
  belongs_to :invoice,        required: false
  belongs_to :property,       required: false
  belongs_to :user,           required: false

  # storage

  has_one_attached :asset

  # helpers

  def name
    self[:name].presence || filename
  end

  def content_type
    asset.try(:content_type)
  end

  def filename
    asset.try(:filename).try(:to_s)
  end

  def filename=(val)
    # asset.present? && asset.blob.update!(filename: val)
  end

  def url
    asset.try(:url)
  end

  def is_pmp?
    tags.include?(SystemTags::PMP)
  end

  def is_walkthrough_report?
    tags.include?(SystemTags::WALKTHROUGH_REPORT)
  end

  # def signed_asset=(val)
  #   puts val
  #   self.asset = ActiveStorage::Blob.find_signed(val)
  # end

  # def signed_asset
  #   nil
  # end

  # no-op
  # needed for resource parity

  def content_type=(val)
  end

  def url=(val)
  end
end
