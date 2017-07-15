class CreateOrderItems < ActiveRecord::Migration[5.0]
  def change
    create_table :order_items do |t|
      t.decimal :h_odd
      t.decimal :a_odd
      t.decimal :d_odd
      t.integer :offer_id
      t.integer :match_id

      t.timestamps
    end
  end
end
