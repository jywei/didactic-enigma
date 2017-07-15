class AddIsRunningToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :is_running, :boolean, default: false
  end
end
