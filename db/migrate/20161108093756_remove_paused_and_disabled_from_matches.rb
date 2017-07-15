class RemovePausedAndDisabledFromMatches < ActiveRecord::Migration[5.0]
  def change
    remove_column :matches, :paused
    remove_column :matches, :disabled
  end
end
