class Stripe::DeleteCustomerJob < ApplicationJob
  queue_as :default

  def perform(stripe_customer_id)
    return unless stripe_customer_id.present?

    Stripe::Customer.delete(stripe_customer_id)
  end
end
