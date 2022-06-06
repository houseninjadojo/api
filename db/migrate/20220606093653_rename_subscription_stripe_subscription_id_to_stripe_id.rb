class RenameSubscriptionStripeSubscriptionIdToStripeId < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :subscriptions, :stripe_subscription_id, :stripe_id
    end
  end
end
