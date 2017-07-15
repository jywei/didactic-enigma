class AddSportNameToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :sport_name, :string
  end
end
