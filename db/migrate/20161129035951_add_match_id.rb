class AddMatchId < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :match_id
    add_column    :order_items, :match_id, :integer
  end
end
