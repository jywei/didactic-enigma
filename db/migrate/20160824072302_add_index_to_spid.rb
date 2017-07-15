class AddIndexToSpid < ActiveRecord::Migration[5.0]
  def change
    add_index :categories, :spid
  end
end
