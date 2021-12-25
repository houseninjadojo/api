class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true

      t.float :lot_size
      t.float :home_size
      t.float :garage_size
      t.integer :year_built
      t.string  :estimated_value
      t.float :bedrooms
      t.float :bathrooms
      t.float :pools

      t.timestamps
    end
  end
end
