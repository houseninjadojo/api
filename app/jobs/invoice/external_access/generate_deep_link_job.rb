class Invoice::ExternalAccess::GenerateDeepLinkJob < ApplicationJob
  queue_as :default

  attr_accessor :invoice, :deep_link

  def perform(invoice)
    @invoice = invoice
    return unless conditions_met?

    invoice.generate_access_token!
    generate_deep_link!
    set_hubspot_branch_payment_link!
  end

  def conditions_met?
    [
      invoice.present?,
      invoice.work_order.present?,
      invoice.work_order.hubspot_id.present?,
    ].all?
  end

  def set_hubspot_branch_payment_link!
    res = Hubspot::Deal.update!(
      invoice.work_order.hubspot_id,
      { "branch_payment_link" => deep_link.url }
    )
  end

  def generate_deep_link!
    @deep_link = DeepLink.create_and_generate!(
      linkable: invoice,
      feature: "invoice_external_access",
      stage: invoice.status,
      data: {
        access_token: invoice.encrypted_access_token,
        "$canonical_url" => "https://app.houseninja.co/p/approve-payment?access_token=#{invoice.encrypted_access_token}",
        "$deeplink_path" => "p/approve-payment?access_token=#{invoice.encrypted_access_token}",
        "$web_only" => false,
      },
    )
  end
end
