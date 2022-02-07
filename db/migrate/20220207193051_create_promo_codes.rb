class CreatePromoCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :promo_codes, id: :uuid do |t|
      t.boolean :active, null: false, default: false

      t.string :code, null: false
      t.string :name
      t.string :percent_off

      t.string :stripe_id
      t.jsonb  :stripe_object

      t.timestamps
    end

    add_index :promo_codes, :code,      unique: true
    add_index :promo_codes, :stripe_id, unique: true
  end
end
