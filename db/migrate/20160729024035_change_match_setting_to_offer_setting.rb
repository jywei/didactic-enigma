class ChangeMatchSettingToOfferSetting < ActiveRecord::Migration[5.0]
  def change
    rename_column :match_settings, :match_id, :offer_id
    rename_table :match_settings, :offer_settings
  end
end
