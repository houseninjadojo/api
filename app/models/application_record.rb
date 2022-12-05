class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to database: {
    writing: :primary,
    reading: :primary_replica
  }

  scope :arrivy, -> { where.not(arrivy_id: nil) }
  scope :hubspot, -> { where.not(hubspot_id: nil) }
  scope :stripe, -> { where.not(stripe_id: nil) }
  scope :intercom, -> { where.not(intercom_id: nil) }

  extend ActiveHash::Associations::ActiveRecordExtensions
end
