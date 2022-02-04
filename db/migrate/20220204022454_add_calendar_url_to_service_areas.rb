class AddCalendarUrlToServiceAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :service_areas, :calendar_url, :string
  end
end
