class AddSportIdToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :sport_id, :integer
  end
end
