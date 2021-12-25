class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true

      t.integer :lot_size
      t.integer :home_size
      t.integer :garage_size
      t.integer :home_age
      t.string  :estimated_value
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :pools

      t.timestamps
    end
  end
end
