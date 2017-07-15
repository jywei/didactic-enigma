class AddCountryNameToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :country_name, :string
  end
end
