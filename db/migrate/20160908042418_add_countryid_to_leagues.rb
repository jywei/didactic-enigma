class AddCountryidToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :country_id, :integer
  end
end
