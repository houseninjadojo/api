# == Schema Information
#
# Table name: home_care_tips
#
#  id                      :uuid             not null, primary key
#  default_hn_chat_message :string           default("")
#  description             :string
#  label                   :string           not null
#  other_provider          :string
#  service_provider        :string
#  show_button             :boolean          default(TRUE), not null
#  time_of_year            :string
#  week                    :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_home_care_tips_on_label  (label)
#  index_home_care_tips_on_week   (week)
#
FactoryBot.define do
  factory :home_care_tip do
    label { "Tip Label" }
    description { Faker::Lorem.sentences(number: 1) }
    show_button { true }
    default_hn_chat_message { "" }
    other_provider { "" }
    service_provider { "" }
    time_of_year { "Any" }
    week { Date.current.cweek }
  end
end
