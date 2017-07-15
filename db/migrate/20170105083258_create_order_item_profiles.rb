class CreateOrderItemProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :order_item_profiles do |t|
      t.integer  "order_item_id"
      t.string   "hteam_name"
      t.string   "ateam_name"
      t.string   "category_name"
      t.string   "halves"
      t.datetime "match_start_time"

      t.timestamps
    end
  end
end
