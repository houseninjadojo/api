# == Schema Information
#
# Table name: document_groups
#
#  id          :uuid             not null, primary key
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_document_groups_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class DocumentGroupResource < ApplicationResource
  self.model = DocumentGroup
  self.type = 'document-groups'

  primary_endpoint 'document-groups'

  belongs_to :user
  has_many :documents

  attribute :id, :uuid

  attribute :name, :string
  attribute :description, :string

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
