class EnlargeTextDataSizeForPushLog < ActiveRecord::Migration[5.0]
  def change
    change_column :log_pushes, :log, :text, limit: 16.megabytes - 1
  end
end
