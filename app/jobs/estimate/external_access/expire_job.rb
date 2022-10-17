class Estimate::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default
  unique :until_executed

  attr_accessor :estimate

  def perform(estimate)
    @estimate = estimate
    return unless conditions_met?

    ActiveRecord::Base.transaction do
      estimate.update(access_token: nil)
      deep_link&.expire!
    end
  end

  def conditions_met?
    [
      estimate.present?,
      deep_link.present?,
    ].all?
  end

  def deep_link
    @deep_link ||= DeepLink.find_by(linkable: estimate)
  end
end
