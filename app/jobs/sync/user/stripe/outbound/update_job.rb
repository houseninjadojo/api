class Sync::User::Stripe::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changeset

  def perform(user, changeset)
    @changeset = changeset
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
    Sync::User::Stripe::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end
end
