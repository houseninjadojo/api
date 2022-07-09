class Sync::User::Intercom::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user, :changeset

  def perform(user, changeset)
    @changeset = changeset
    return unless policy.can_sync?

    contact = intercom.contacts.find(id: user.intercom_id)
    params.each do |key, val|
      contact.instance_variable_set("@#{key}", val)
    end
    intercom.contacts.save(contact)
  end

  def params
    {
      role: "user",
      name: user.full_name,
      email: user.email,
      phone: user.phone_number,
      external_id: user.id,
    }
  end

  def policy
    Sync::User::Intercom::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end

  def intercom
    @intercom ||= Intercom::Client.new(
      token: Rails.secrets.dig(:intercom, :access_token)
    )
  end
end
