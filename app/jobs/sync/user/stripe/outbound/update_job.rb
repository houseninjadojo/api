class Sync::User::Stripe::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user, :changeset

  retry_on Stripe::APIConnectionError, wait: 5.minutes, attempts: 3
  discard_on Stripe::StripeError

  def perform(user, changeset)
    @changeset = changeset
    @user = user
    
    unless policy.can_sync?
      Rails.logger.info(
        "Sync::User::Stripe::Outbound::UpdateJob - Skipping Sync",
        usr: { id: user.id, email: user.email },
        active_job: { id: job_id, class: self.class.name },
        changeset: changeset
      )
      return
    end

    begin
      Stripe::Customer.update(user.stripe_id, params, { idempotency_key: idempotency_key })
    rescue Stripe::APIConnectionError => e
      Rails.logger.warn(
        "Stripe - API Connection Error Updating User `#{user&.stripe_id}`",
        usr: { id: user&.id, email: user&.email },
        active_job: { id: job_id, class: self.class.name },
        error: e
      )
      raise e
    rescue Stripe::StripeError => e
      Rails.logger.error(
        "Stripe - Error Updating User `#{user&.stripe_id}`",
        usr: { id: user&.id, email: user&.email },
        active_job: { id: job_id, class: self.class.name },
        error: e
      )
      raise e
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
