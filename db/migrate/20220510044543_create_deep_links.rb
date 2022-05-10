class CreateDeepLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :deep_links, id: :uuid do |t|
      t.references :linkable, type: :uuid, polymorphic: true, index: true

      t.string :url
      t.string :feature
      t.string :campaign
      t.string :stage
      t.string :tags, array: true, default: []
      t.jsonb :data

      t.string :canonical_url
      t.string :path

      t.timestamp :expires_at

      t.timestamps
    end
  end
end
