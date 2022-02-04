class AddDefaultAndSelectedToProperties < ActiveRecord::Migration[7.0]
  def change
    add_column :properties, :default, :boolean
    add_column :properties, :selected, :boolean

    add_index :properties, [:user_id, :default], unique: true
    add_index :properties, [:user_id, :selected]
  end
end
