class ChangeTimeToDatetime < ActiveRecord::Migration[5.0]
  def change
    change_column :matches, :start_time, :datetime
  end
end
