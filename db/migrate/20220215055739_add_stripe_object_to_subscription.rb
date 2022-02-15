class AddStripeObjectToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :stripe_object, :jsonb
  end
end
