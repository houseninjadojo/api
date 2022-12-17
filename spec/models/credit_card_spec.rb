# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  brand        :string
#  card_number  :string
#  country      :string
#  cvv          :string
#  deleted_at   :datetime
#  exp_month    :string
#  exp_year     :string
#  last_four    :string
#  stripe_token :string
#  type         :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
