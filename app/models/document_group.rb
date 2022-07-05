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
class DocumentGroup < ApplicationRecord
  DEFAULT_GROUPS = [
    # "Invoices",
    "Insurance",
    "Manuals",
    "Home Warranty",
    "Home Inspection Reports",
    "Paint Colors",
    "Permits",
    "Misc",
  ]


  # associations

  belongs_to :user
  has_many :documents, dependent: :nullify

  # attributes

  def owner=(val)
    # no-op
  end

  def owner
    # no-op
  end
end
