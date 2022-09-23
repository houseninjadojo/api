class Estimate::ExternalAccess::ExpireJob < ApplicationJob
  queue_as :default
  unique :until_executed

  attr_accessor :estimate

  def perform(estimate)
    @estimate = estimate
    return unless conditions_met?

    ActiveRecord::Base.transaction do
      estimate.update(access_token: nil)
      DeepLink.find_by(linkable: estimate)&.expire!
    end
  end

  def conditions_met?
    [
      estimate.present?,
      estimate.deep_link.present?,
    ].all?
  end
end
