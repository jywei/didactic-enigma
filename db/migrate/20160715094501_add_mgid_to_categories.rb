class AddMgidToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :mgid, :integer
  end
end
