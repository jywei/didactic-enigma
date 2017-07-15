class CreateOfferPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :offer_positions do |t|
      t.decimal :h_position, precision: 9, scale: 3
      t.decimal :a_position, precision: 9, scale: 3
      t.decimal :d_position, precision: 9, scale: 3
      t.decimal :h_distance, precision: 9, scale: 3
      t.decimal :a_distance, precision: 9, scale: 3
      t.decimal :d_distance, precision: 9, scale: 3
      t.decimal :h_threshold, precision: 9, scale: 3
      t.decimal :a_threshold, precision: 9, scale: 3
      t.decimal :d_threshold, precision: 9, scale: 3
      t.integer :offer_id

      t.timestamps
    end
  end
end
