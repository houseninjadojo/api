# == Schema Information
#
# Table name: document_groups
#
#  id          :uuid             not null, primary key
#  user_id     :uuid             not null
#  name        :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_document_groups_on_user_id  (user_id)
#
class DocumentGroup < ApplicationRecord

  # associations

  belongs_to :user
  has_many :documents

  # attributes

  def owner=(val)
    # no-op
  end

  def owner
    # no-op
  end

  # helpers

end
