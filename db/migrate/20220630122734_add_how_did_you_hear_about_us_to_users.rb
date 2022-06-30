class AddHowDidYouHearAboutUsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :how_did_you_hear_about_us, :string
  end
end
