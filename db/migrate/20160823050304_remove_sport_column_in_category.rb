class RemoveSportColumnInCategory < ActiveRecord::Migration[5.0]
  def change
    remove_column :categories, :sport
  end
end
