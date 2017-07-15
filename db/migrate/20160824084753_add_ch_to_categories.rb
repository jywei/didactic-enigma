class AddChToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :ch, :string
  end
end
