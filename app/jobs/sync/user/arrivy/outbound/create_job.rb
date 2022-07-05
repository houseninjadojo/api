class Sync::User::Arrivy::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user
    return unless policy.can_sync?

    customer = Arrivy::Customer.new(params).create
    user.update!(arrivy_id: customer.id)
  end

  def params
    {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone: user.phone_number,
      mobile_number: user.phone_number,
      external_id: user.id,
    }
  end

  def policy
    Sync::User::Arrivy::Outbound::CreatePolicy.new(
      user
    )
  end
end
