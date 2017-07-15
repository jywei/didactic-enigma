class ChangePausedToDisabled < ActiveRecord::Migration[5.0]
  def change
    rename_column :matches, :hidden, :paused
  end
end
