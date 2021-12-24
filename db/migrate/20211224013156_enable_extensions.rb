class EnableExtensions < ActiveRecord::Migration[7.0]
  def change
    # Enable Crypto
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
