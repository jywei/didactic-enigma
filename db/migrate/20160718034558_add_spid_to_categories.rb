class AddSpidToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :spid, :integer
  end
end
