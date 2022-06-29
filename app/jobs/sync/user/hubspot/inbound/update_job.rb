class Sync::User::Hubspot::Inbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :webhook_entry, :webhook_event

  delegate :resource, :attribute_name, :attribute_value, :handle_as_document?, :document_tag, to: :entry

  def perform(webhook_event, webhook_entry)
    @webhook_entry = webhook_entry
    @webhook_event = webhook_event

    return unless policy.can_sync?

    if handle_as_document?
      upsert_document!
    else
      resource.update!(attribute_name => attribute_value)
    end

    webhook_event.update!(processed_at: Time.now)
  end

  def policy
    Sync::User::Hubspot::Inbound::UpdatePolicy.new(
      webhook_entry,
      webhook_event: webhook_event
    )
  end

  def entry
    Hubspot::Webhook::Entry.new(webhook_event, webhook_entry)
  end

  def upsert_document!
    Document.find_by(user: resource, tags: [document_tag])&.destroy!
    document = Document.create!(user: user, tags: [document_tag])
    document.asset.attach(io: attribute_value, filename: "#{document_tag}.pdf")
    document.save!
  end
end
