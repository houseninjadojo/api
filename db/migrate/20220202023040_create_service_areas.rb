class CreateServiceAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :service_areas, id: :uuid do |t|
      t.string :name, null: false
      t.string :zipcodes, array: true, null: false, default: []

      t.timestamps
    end

    add_index :service_areas, :name
    add_index :service_areas, :zipcodes, using: 'gin'

    add_column :properties, :service_area_id, :uuid
    add_index :properties, :service_area_id
  end
end
