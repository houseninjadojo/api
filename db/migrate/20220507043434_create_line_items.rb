class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items, id: :uuid do |t|
      t.references :invoice, type: :uuid, foreign_key: true

      t.string :amount,      null: false, default: '0'
      t.string :description

      t.string :hubspot_id, index: true
      t.string :stripe_id,  index: true
      t.jsonb  :stripe_object

      t.timestamps
    end
  end
end
