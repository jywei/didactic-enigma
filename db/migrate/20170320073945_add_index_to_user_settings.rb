class AddIndexToUserSettings < ActiveRecord::Migration[5.0]
  def change
    add_index :user_settings, :user_id
  end
end
