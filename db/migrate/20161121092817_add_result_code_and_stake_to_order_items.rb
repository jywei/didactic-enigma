class AddResultCodeAndStakeToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :result_code, :string
    add_column :order_items, :stake, :integer
  end
end
