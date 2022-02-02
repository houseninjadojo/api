class CreateHomeCareTips < ActiveRecord::Migration[7.0]
  def change
    create_table :home_care_tips, id: :uuid do |t|
      t.string :label, null: false, index: true
      t.string :description
      t.boolean :show_button, default: true, null: false
      t.string :default_hn_chat_message, default: ""

      t.timestamps
    end
  end
end
