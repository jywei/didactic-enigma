class AddDefaultToSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :match_settings, :default, :boolean, default: false
  end
end
