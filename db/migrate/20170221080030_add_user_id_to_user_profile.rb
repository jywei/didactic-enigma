class AddUserIdToUserProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :user_profiles, :user_id, :integer
  end
end
