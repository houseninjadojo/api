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
require 'rails_helper'

RSpec.describe DocumentGroup, type: :model do
  describe 'associations' do
    subject { build(:document_group) }
    it { should belong_to(:user) }
    it { should have_many(:documents).dependent(:nullify) }
  end

  describe 'validations' do
    subject { build(:document_group) }
  end
end
