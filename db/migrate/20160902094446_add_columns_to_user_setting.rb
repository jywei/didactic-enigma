class AddColumnsToUserSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :user_settings, :name_ch, :string
  end
end
