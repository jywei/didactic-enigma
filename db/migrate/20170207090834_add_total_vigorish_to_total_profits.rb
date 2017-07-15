class AddTotalVigorishToTotalProfits < ActiveRecord::Migration[5.0]
  def change
    add_column :total_profits, :total_vigorish, :decimal, precision: 12, scale: 3
  end
end
