# == Schema Information
#
# Table name: subscription_plans
#
#  id         :uuid             not null, primary key
#  slug       :string           not null
#  name       :string           not null
#  price      :string           not null
#  interval   :string           not null
#  perk       :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscription_plans_on_interval  (interval)
#  index_subscription_plans_on_slug      (slug)
#
FactoryBot.define do
  factory :subscription_plan do
    slug { "annual" }
    name { "Annual" }
    price { "539" }
    interval { "year" }
    perk { "1 month free" }
  end
end
