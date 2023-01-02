class AddDefaultToPaymentMethods < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :users, :default_payment_method_id, :uuid, null: true, index: { algorithm: :concurrently }
  end
end
