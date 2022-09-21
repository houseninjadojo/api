class Sync::Estimate::Hubspot::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :estimate, :changeset

  def perform(estimate, changeset)
    @changeset = changeset
    @estimate = estimate
    return unless policy.can_sync?

    Hubspot::Deal.update!(estimate.work_order.hubspot_id, params)
  end

  def params
    {
      estimate_approved: estimate_approved,
    }
  end

  def policy
    Sync::Estimate::Hubspot::Outbound::UpdatePolicy.new(
      estimate,
      changeset: changeset
    )
  end

  def estimate_approved
    if estimate.approved
      "Yes"
    # elsif  declined_at
      "No"
    end
  end
end
