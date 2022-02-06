class AddHubspotIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :hubspot_id, :string
    add_index  :users, :hubspot_id, unique: true
  end
end
