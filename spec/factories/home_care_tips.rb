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
FactoryBot.define do
  factory :home_care_tip do
    label { "Tip Label" }
    description { Faker::Lorem.sentences(number: 1) }
    show_button { true }
    default_hn_chat_message { "" }
  end
end
