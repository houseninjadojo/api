class AddLastFourToPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_methods, :last_four, :string
  end
end
