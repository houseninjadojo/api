class Sync::User::Arrivy::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changeset

  def perform(user, changeset)
    @changeset = changeset
    @user = user
    return unless policy.can_sync?

    Arrivy::Customer.new(params).update
  end

  def params
    {
      id: user.arrivy_id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone: user.phone_number,
      mobile_number: user.phone_number,
      external_id: user.id,
    }
  end

  def policy
    Sync::User::Arrivy::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end
end
