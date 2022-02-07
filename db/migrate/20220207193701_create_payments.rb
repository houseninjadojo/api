class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :invoice,        type: :uuid, foreign_key: true
      t.references :user,           type: :uuid, foreign_key: true
      t.references :payment_method, type: :uuid, foreign_key: true

      t.string :amount
      t.string :description
      t.string :statement_descriptor
      t.string :status

      t.boolean :refunded, null: false, default: false
      t.boolean :paid,     null: false, default: false

      t.string :stripe_id
      t.jsonb  :stripe_object

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, :stripe_id, unique: true
  end
end
