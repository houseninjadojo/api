class AddDeeplinkPathToDeepLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :deep_links, :deeplink_path, :string
  end
end
