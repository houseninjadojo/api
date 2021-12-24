class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name,   null: false,              comment: "First Name"
      t.string :last_name,    null: false,              comment: "Last Name"
      t.string :email,        null: false, default: "", comment: "Email Address"
      t.string :phone_number, null: false,              comment: "Phone Number (+15555555555)"

      t.timestamps
    end

    add_index :users, :email,        unique: true
    add_index :users, :phone_number, unique: true
  end
end
