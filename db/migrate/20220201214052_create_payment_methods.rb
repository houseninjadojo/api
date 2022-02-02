class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods, id: :uuid do |t|
      t.string :type
      t.references :user, type: :uuid, foreign_key: true, null: false

      t.string :stripe_token
      t.string :brand
      t.string :country
      t.string :cvv
      t.string :exp_month
      t.string :exp_year
      t.string :card_number
      t.string :zipcode

      t.timestamps
    end

    add_index :payment_methods, :stripe_token, unique: true
  end
end
