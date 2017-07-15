class AddEffectiveAmountToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :effective_amount, :integer
  end
end
