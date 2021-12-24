class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.references :addressible, type: :uuid, polymorphic: true

      t.string :street1
      t.string :street2
      t.string :city,    index: true
      t.string :zipcode, index: true
      t.string :state,   index: true

      t.timestamps
    end
  end
end
