class AddIndexToActiveSubscriptionPlans < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :subscription_plans, :active, unique: false, algorithm: :concurrently
  end
end
