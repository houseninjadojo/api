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
class DocumentResource < ApplicationResource
  self.model = Document
  self.type = :documents

  primary_endpoint 'documents', [:index, :show, :create, :update, :destroy]

  belongs_to :document_group
  belongs_to :invoice
  belongs_to :payment
  belongs_to :property
  belongs_to :user

  attribute :id, :uuid

  attribute :invoice_id,        :uuid, only: [:filterable]
  attribute :payment_id,        :uuid, only: [:filterable]
  attribute :property_id,       :uuid, only: [:filterable]
  attribute :user_id,           :uuid, only: [:filterable]
  attribute :document_group_id, :uuid, only: [:filterable], allow_nil: true

  attribute :content_type, :string, only: [:readable]
  attribute :filename,     :string, only: [:readable]
  attribute :url,          :string, only: [:readable]

  attribute :name,        :string
  attribute :description, :string

  attribute :tags, :array

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  attribute :asset, :string, except: [:readable, :sortable, :filterable]

  # treat 'uncategorized' as 'all documents without a document group'
  filter :document_group_id, :uuid do
    eq do |scope, value|
      if value == ['uncategorized']
        scope.where(document_group_id: nil)
      else
        scope.where(document_group_id: value)
      end
    end
  end

  # we need to call this out explicitly
  before_attributes do |attributes|
    if attributes[:document_group_id].nil?
      attributes[:document_group_id] = nil
    end
  end
end
