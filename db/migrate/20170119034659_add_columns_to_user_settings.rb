class AddColumnsToUserSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :user_settings, :offer_name, :string
    add_column :user_settings, :halves, :string
    add_column :user_settings, :category_id, :integer
  end
end
