# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  type         :string
#  user_id      :uuid             not null
#  stripe_token :string
#  brand        :string
#  country      :string
#  cvv          :string
#  exp_month    :string
#  exp_year     :string
#  card_number  :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_four    :string
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
