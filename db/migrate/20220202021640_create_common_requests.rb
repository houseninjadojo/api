class CreateCommonRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :common_requests, id: :uuid do |t|
      t.string :caption
      t.string :img_uri
      t.string :default_hn_chat_message

      t.timestamps
    end
  end
end
