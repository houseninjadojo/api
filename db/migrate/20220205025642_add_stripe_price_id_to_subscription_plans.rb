class AddStripePriceIdToSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :subscription_plans, :stripe_price_id, :string
    add_index :subscription_plans, :stripe_price_id, unique: true
  end
end
