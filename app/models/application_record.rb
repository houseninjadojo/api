class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :arrivy, -> { where.not(arrivy_id: nil) }
  scope :hubspot, -> { where.not(hubspot_id: nil) }
  scope :stripe, -> { where.not(stripe_id: nil) }
  scope :intercom, -> { where.not(intercom_id: nil) }
end
