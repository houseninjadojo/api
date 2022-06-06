class Stripe::CreateCustomerJob < ApplicationJob
  queue_as :critical

  def perform(user)
    ActiveSupport::Deprecation.warn('use Sync::User::Stripe::Outbound::CreateJob instead')

    return if user.stripe_id.present?

    params = params(user)
    customer = Stripe::Customer.create(params)
    user.update!(stripe_id: customer.id)
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
