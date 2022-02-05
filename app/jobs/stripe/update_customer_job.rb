class Stripe::UpdateCustomerJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.stripe_customer_id.present?

    params = params(user)
    Stripe::Customer.update(user.stripe_customer_id, params)
  end

  def params(user)
    {
      description: user.full_name,
      email: user.email,
      name: user.full_name,
      phone: user.phone_number,
    }
  end
end
