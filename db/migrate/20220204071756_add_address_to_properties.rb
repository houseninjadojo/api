class AddAddressToProperties < ActiveRecord::Migration[7.0]
  def change
    add_column :properties, :street_address1, :string
    add_column :properties, :street_address2, :string
    add_column :properties, :city, :string
    add_column :properties, :zipcode, :string
    add_column :properties, :state, :string

    add_index :properties, :city
    add_index :properties, :state
    add_index :properties, :zipcode
  end
end
