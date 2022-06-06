class RenameUserStripeCustomerIdToStripeId < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :users, :stripe_customer_id, :stripe_id
    end
  end
end
