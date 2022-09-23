class Estimate::ExternalAccess::GenerateDeepLinkJob < ApplicationJob
  queue_as :default
  unique :until_expired, runtime_lock_ttl: 1.minute, on_conflict: :log

  attr_accessor :estimate, :deep_link

  def perform(estimate:, send_email: false)
    @estimate = estimate
    return unless conditions_met?

    estimate.generate_access_token!
    generate_deep_link!

    if send_email
      estimate.send_estimate_approval_email!
    end
  end

  def conditions_met?
    [
      estimate.present?,
      estimate.work_order.present?,
      estimate.work_order.hubspot_id.present?,
    ].all?
  end

  def escaped_access_token
    CGI.escape(estimate.encrypted_access_token)
  end

  def canonical_url
    "https://#{Rails.settings.domains[:app]}/p/approve-estimate/#{escaped_access_token}"
  end

  def deeplink_path
    "/work-orders/#{estimate.work_order&.id}"
  end

  def generate_deep_link!
    @deep_link = DeepLink.create_and_generate!(
      canonical_url: canonical_url,
      deeplink_path: deeplink_path,
      feature: "estimate_external_access",
      linkable: estimate,
      path: canonical_url,
      stage: estimate.status,
      data: {
        access_token: estimate.encrypted_access_token,
        # "$canonical_url" => canonical_url,
        # "$deeplink_path" => deeplink_path,
        "$web_only" => false,
      },
    )
  end
end
