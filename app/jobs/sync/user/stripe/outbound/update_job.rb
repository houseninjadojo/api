class Sync::User::Stripe::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  retry_on Stripe::APIConnectionError, wait: 5.minutes, attempts: 3 do |job, error|
    Rails.logger.warn(
      "Stripe - API Connection Error Updating User `#{user&.stripe_id}`",
      usr: { id: user&.id, email: user&.email },
      active_job: { id: job&.job_id },
      error: error
    )
  end

  discard_on Stripe::StripeError do |job, error|
    Rails.logger.error(
      "Stripe - Error Updating User `#{user&.stripe_id}`",
      usr: { id: user&.id, email: user&.email },
      active_job: { id: job.job_id },
      error: e
    )
  end

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
