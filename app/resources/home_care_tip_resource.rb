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
class HomeCareTipResource < ApplicationResource
  self.model = HomeCareTip
  self.type = 'home-care-tips'

  primary_endpoint 'home-care-tips', [:index, :show]

  attribute :id, :uuid

  attribute :label,       :string,  except: [:writeable]
  attribute :description, :string,  except: [:sortable, :writeable]
  attribute :show_button, :boolean, except: [:sortable, :writeable]
  attribute :default_hn_chat_message, :string, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
