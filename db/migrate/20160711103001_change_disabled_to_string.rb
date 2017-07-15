class ChangeDisabledToString < ActiveRecord::Migration[5.0]
  def up
    remove_column :offers, :disabled
    change_column :matches, :disabled, :string, default: ''
    add_column :matches, :hidden, :string, default: ''
  end

  def down
    add_column :offers, :disabled, :boolean
    remove_column :matches, :hidden
    change_column :matches, :disabled, :boolean
  end
end
