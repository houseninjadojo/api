class AddDeletedAtToPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_methods, :deleted_at, :datetime, index: true
  end
end
