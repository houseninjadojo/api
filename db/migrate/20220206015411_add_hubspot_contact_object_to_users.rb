class AddHubspotContactObjectToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :hubspot_contact_object, :jsonb
  end
end
