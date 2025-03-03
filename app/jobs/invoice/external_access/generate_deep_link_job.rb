class Invoice::ExternalAccess::GenerateDeepLinkJob < ApplicationJob
  queue_as :default
  unique :until_expired, runtime_lock_ttl: 1.minute

  attr_accessor :invoice, :deep_link

  def perform(invoice:, send_email: false)
    @invoice = invoice
    return unless conditions_met?

    invoice.generate_access_token!
    generate_deep_link!

    if send_email
      invoice.send_payment_approval_email!
    end
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.work_order.present?,
      invoice.work_order.hubspot_id.present?,
    ].all?
  end

  def escaped_access_token
    CGI.escape(invoice.encrypted_access_token)
  end

  def canonical_url
    "https://#{Rails.settings.domains[:app]}/p/approve-payment/#{escaped_access_token}"
  end

  def deeplink_path
    "/work-orders/#{invoice.work_order&.id}"
  end

  def generate_deep_link!
    @deep_link = DeepLink.create_and_generate!(
      canonical_url: canonical_url,
      deeplink_path: deeplink_path,
      feature: "invoice_external_access",
      linkable: invoice,
      path: canonical_url,
      stage: invoice.status,
      data: {
        access_token: invoice.encrypted_access_token,
        # "$canonical_url" => canonical_url,
        # "$deeplink_path" => deeplink_path,
        "$web_only" => false,
      },
    )
  end
end
