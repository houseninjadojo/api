class RenameDeepLinkExpiresAtToExpiredAt < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :deep_links, :expires_at, :expired_at }
  end
end
