# == Schema Information
#
# Table name: home_care_tips
#
#  id                      :uuid             not null, primary key
#  label                   :string           not null
#  description             :string
#  show_button             :boolean          default(TRUE), not null
#  default_hn_chat_message :string           default("")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_home_care_tips_on_label  (label)
#
require 'rails_helper'

RSpec.describe HomeCareTip, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
