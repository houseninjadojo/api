class AddOriginatorToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :originator, :string
  end
end
