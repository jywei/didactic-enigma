class AddArchiveToLogErrors < ActiveRecord::Migration[5.0]
  def change
    add_column :log_errors, :archive, :boolean, default: false
  end
end
