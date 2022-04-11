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
class DocumentResource < ApplicationResource
  self.model = Document
  self.type = :documents

  primary_endpoint 'documents', [:index, :show]

  belongs_to :document_group
  belongs_to :invoice
  belongs_to :property
  belongs_to :user

  attribute :id, :uuid

  attribute :invoice_id,        :uuid, only: [:filterable]
  attribute :property_id,       :uuid, only: [:filterable]
  attribute :user_id,           :uuid, only: [:filterable]
  attribute :document_group_id, :uuid, only: [:filterable]

  attribute :content_type, :string, only: [:readable]
  attribute :filename,     :string, only: [:readable]
  attribute :url,          :string, only: [:readable]

  attribute :name,        :string
  attribute :description, :string

  attribute :tags, :array

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
