class Sync::User::Stripe::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user
    return unless policy.can_sync?

    customer = Stripe::Customer.create(params)
    user.update!(stripe_id: customer.id)
  end

  def params
    {
      description: user.full_name,
      email: user.email,
      name: user.full_name,
      phone: user.phone_number,
    }
  end

  def policy
    Sync::User::Stripe::Outbound::CreatePolicy.new(
      user
    )
  end
end
