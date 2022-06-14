class Sync::User::Stripe::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changeset

  def perform(user, changeset)
    @changeset = changeset
    @user = user
    return unless policy.can_sync?

    Stripe::Customer.update(user.stripe_id, params, { idempotency_key: idempotency_key })
  end

  def params
    {
      description: user.full_name,
      email: user.email,
      name: user.full_name,
      phone: user.phone_number,
      metadata: {
        house_ninja_id: user.id,
      },
    }
  end

  def policy
    Sync::User::Stripe::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{user.id}#{user.updated_at.to_i}")
  end
end
