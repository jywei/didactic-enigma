class AddColumnToUserSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :user_allotters, :name, :string
    add_column :user_settings, :name, :string
    add_column :user_settings, :otname, :string
    add_column :user_settings, :ot_id, :integer
  end
end
