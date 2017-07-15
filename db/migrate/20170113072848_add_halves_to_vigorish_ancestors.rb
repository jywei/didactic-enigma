class AddHalvesToVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    add_column :vigorish_ancestors, :halves, :string
  end
end
