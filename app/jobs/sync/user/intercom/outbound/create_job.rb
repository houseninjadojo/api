class Sync::User::Intercom::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user
    return unless policy.can_sync?

    begin
      contact = intercom.contacts.create(params)
    rescue Intercom::MultipleMatchingUsersError => error
      # match: "A contact matching those details already exists with id=12345asdf"
      id = error.message.match(/id=([a-z0-9]+)$/)[1]
      contact = intercom.contacts.find(id: id)
      contact.external_id = user.id
      intercom.contacts.save(contact)
    end
    user.update!(intercom_id: contact.id)
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
    Sync::User::Intercom::Outbound::CreatePolicy.new(
      user
    )
  end

  def intercom
    @intercom ||= Intercom::Client.new(token: Rails.secrets.dig(:intercom, :access_token))
  end
end
