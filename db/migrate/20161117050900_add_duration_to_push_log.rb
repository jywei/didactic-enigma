class AddDurationToPushLog < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :log_start, :float
    add_column :log_pushes, :log_duration, :float
  end
end
