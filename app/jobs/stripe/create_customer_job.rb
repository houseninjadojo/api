class Stripe::CreateCustomerJob < ApplicationJob
  queue_as :critical

  def perform(user)
    return if user.stripe_customer_id.present?

    params = params(user)
    customer = Stripe::Customer.create(params)
    user.update!(stripe_customer_id: customer.id)
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
