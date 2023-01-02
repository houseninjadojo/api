class AddForeignKeyToDefaultPaymentMethod < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :users, :payment_methods, column: :default_payment_method_id, validate: false
  end
end
