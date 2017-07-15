class AddTeamToOrderItems < ActiveRecord::Migration[5.0]
  def change
    add_column :order_items, :team, :string
  end
end
