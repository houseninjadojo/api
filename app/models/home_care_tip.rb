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
class HomeCareTip < ApplicationRecord
  # validations
  validates :show_button, presence: true, inclusion: { in: [true, false] }
  validates :label,       presence: true
  validates :week,        presence: true

  scope :current, -> {
    where(week: 0..Date.current.cweek).order(week: :desc).limit(1)
  }
end
