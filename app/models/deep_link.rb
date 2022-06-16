# == Schema Information
#
# Table name: deep_links
#
#  id            :uuid             not null, primary key
#  campaign      :string
#  canonical_url :string
#  data          :jsonb
#  deeplink_path :string
#  expired_at    :datetime
#  feature       :string
#  linkable_type :string
#  path          :string
#  stage         :string
#  tags          :string           default([]), is an Array
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  linkable_id   :uuid
#
# Indexes
#
#  index_deep_links_on_linkable  (linkable_type,linkable_id)
#
class DeepLink < ApplicationRecord
  belongs_to :linkable, polymorphic: true, required: false

  # callbacks

  before_destroy :delete_branch_link

  def generate!
    return if is_generated?
    update!(url: BranchLink.create(branch_link_params).url)
  end

  def branch_link_params
    attributes.with_indifferent_access.slice(
      :campaign,
      :channel,
      :feature,
      :stage,
      :tags
    ).merge({
      data: data,
    })
  end

  def is_generated?
    url.present?
  end

  def is_expired?
    expired_at.present? && expired_at < Time.now
  end

  def to_s
    is_expired? ? nil : url
  end

  def deeplink_path
    super || path
  end

  def data
    (super.presence || {}).merge({
      "$canonical_url" => canonical_url,
      "$deeplink_path" => deeplink_path,
      "$desktop_url" => canonical_url,
    })
  end

  def expire!
    delete_branch_link
    update!(expired_at: Time.now)
  end

  def self.create_and_generate!(params)
    deep_link = create!(params)
    deep_link.generate!
    deep_link.reload
  end

  private

  def delete_branch_link
    begin
      BranchLink.find(url)&.destroy
    rescue => e
      Rails.logger.error "Error deleting branch link: #{e.message}"
      Sentry.capture_exception(e)
    end
  end
end
