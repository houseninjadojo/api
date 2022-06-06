class Stripe::DeleteCustomerJob < ApplicationJob
  queue_as :default

  def perform(stripe_id)
    return unless stripe_id.present?

    # Stripe::Customer.delete(stripe_id)
  end
end
