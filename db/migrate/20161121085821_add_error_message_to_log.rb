class AddErrorMessageToLog < ActiveRecord::Migration[5.0]
  def change
    add_column :log_errors, :message, :text
    add_column :log_errors, :params, :text
  end
end
