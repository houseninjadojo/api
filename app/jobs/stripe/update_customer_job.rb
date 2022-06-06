class Stripe::UpdateCustomerJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changed_attributes

  def perform(user, changed_attributes)
    ActiveSupport::Deprecation.warn('use Sync::User::Hubspot::OutboundJob instead')

    @changed_attributes = changed_attributes
    @user = user
    return unless policy.can_sync?

    Stripe::Customer.update(user.stripe_id, params)
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
    Sync::User::Stripe::OutboundPolicy.new(
      user: user,
      changed_attributes: changed_attributes
    )
  end
end
