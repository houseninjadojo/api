class Sync::User::Arrivy::OutboundJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changed_attributes

  def perform(user, changed_attributes)
    @changed_attributes = changed_attributes
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
    Sync::User::Arrivy::OutboundPolicy.new(
      user,
      changed_attributes: changed_attributes
    )
  end
end
