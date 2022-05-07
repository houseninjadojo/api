# == Schema Information
#
# Table name: work_order_statuses
#
#  id         :uuid             not null, primary key
#  name       :string
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hubspot_id :string
#
# Indexes
#
#  index_work_order_statuses_on_hubspot_id  (hubspot_id) UNIQUE
#  index_work_order_statuses_on_slug        (slug) UNIQUE
#
class ApplicationResource < Graphiti::Resource
  # Use the ActiveRecord Adapter for all subclasses.
  # Subclasses can still override this default.
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = "#{Rails.settings.protocol}://#{Rails.settings.domains[:app]}"
  self.endpoint_namespace = '/'

  # Automatically generate JSONAPI links
  self.autolink = true

  def current_user
    context.current_user
  end
end
