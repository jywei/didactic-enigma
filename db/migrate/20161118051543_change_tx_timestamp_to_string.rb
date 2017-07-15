class ChangeTxTimestampToString < ActiveRecord::Migration[5.0]
  def change
    change_column :log_pushes, :tx_timestamp, :string
  end
end
