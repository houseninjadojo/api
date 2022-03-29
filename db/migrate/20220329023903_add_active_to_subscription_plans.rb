class AddActiveToSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :subscription_plans, :active, :boolean, default: false, null: false
  end
end
