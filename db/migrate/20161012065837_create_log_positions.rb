class CreateLogPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :log_positions do |t|
      t.integer :offer_position_id
      t.integer :order_id
      t.decimal :h_position, precision: 9, scale: 3
      t.decimal :a_position, precision: 9, scale: 3
      t.decimal :d_position, precision: 9, scale: 3
      t.decimal :h_threshold, precision: 9, scale: 3
      t.decimal :a_threshold, precision: 9, scale: 3
      t.decimal :d_threshold, precision: 9, scale: 3
      t.decimal :h_distance, precision: 9, scale: 3
      t.decimal :a_distance, precision: 9, scale: 3
      t.decimal :d_distance, precision: 9, scale: 3

      t.timestamps
    end
  end
end
