class Sync::User::Stripe::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user

    ActiveRecord::Base.transaction do
      return unless policy.can_sync?

      customer = Stripe::Customer.create(params, { idempotency_key: idempotency_key })
      user.update!(stripe_id: customer.id)
    end
  end

  def params
    {
      description: user.full_name,
      email: user.email,
      name: user.full_name,
      phone: user.phone_number,
      metadata: {
        house_ninja_id: user.id,
      }
    }
  end

  def policy
    Sync::User::Stripe::Outbound::CreatePolicy.new(
      user
    )
  end

  def idempotency_key
    Digest::SHA256.hexdigest("#{user.id}#{user.updated_at.to_i}")
  end
end
