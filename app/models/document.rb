# == Schema Information
#
# Table name: documents
#
#  id                :uuid             not null, primary key
#  description       :string
#  name              :string
#  tags              :text             default([]), not null, is an Array
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_group_id :uuid
#  invoice_id        :uuid
#  payment_id        :uuid
#  property_id       :uuid
#  user_id           :uuid
#
# Indexes
#
#  index_documents_on_document_group_id  (document_group_id)
#  index_documents_on_invoice_id         (invoice_id)
#  index_documents_on_payment_id         (payment_id)
#  index_documents_on_property_id        (property_id)
#  index_documents_on_tags               (tags) USING gin
#  index_documents_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (property_id => properties.id)
#  fk_rails_...  (user_id => users.id)
#
class Document < ApplicationRecord
  module SystemTags
    PMP = 'system:preventative-maintenance-plan'
    WALKTHROUGH_REPORT = 'system:walkthrough-report'
    INVOICE = 'system:invoice'
    RECEIPT = 'system:receipt'
  end

  # scopes

  # scope :pmp, -> { where(tags: { '$in' => [SystemTags::PMP] }) }
  scope :invoices, -> { where.not(invoice_id: nil) }
  scope :except_invoices, -> { where(invoice_id: nil) }
  scope :for_vault, -> { where(invoice_id: nil, payment_id: nil) }

  # callbacks

  # associations

  belongs_to :document_group, required: false
  belongs_to :invoice,        required: false
  belongs_to :payment,        required: false
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
