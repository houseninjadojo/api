class BackfillUsersFirstWalkthrough < ActiveRecord::Migration[7.0]
  def change
    User.update_all(first_walkthrough_performed: false)
  end
end
