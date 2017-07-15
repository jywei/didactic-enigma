class RenameChToDisplayNameInCategories < ActiveRecord::Migration[5.0]
  def change
    rename_column :categories, :ch, :display_name
  end
end
