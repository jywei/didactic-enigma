class AddParlayCountAndParlaySerialToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :parlay_serial, :string
    add_column :orders, :parlay_count, :integer
    add_column :orders, :is_valid, :boolean
    add_index :orders, :parlay_serial
  end
end
