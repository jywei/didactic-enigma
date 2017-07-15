class CreateLogPositionWarnings < ActiveRecord::Migration[5.0]
  def change
    create_table :log_position_warnings do |t|
      t.integer :match_id
      t.integer :offer_position_id
      t.integer :order_id
      t.integer :sport_id
      t.string :sport_name
      t.integer :category_id
      t.string :category_name
      t.string :h_team
      t.string :a_team
      t.datetime :match_time
      t.string :warning_level
      t.decimal :h_position, precision: 13, scale: 3
      t.decimal :a_position, precision: 13, scale: 3
      t.decimal :d_position, precision: 13, scale: 3
      t.decimal :h_threshold, precision: 13, scale: 3
      t.decimal :a_threshold, precision: 13, scale: 3
      t.decimal :d_threshold, precision: 13, scale: 3
      t.decimal :h_distance, precision: 13, scale: 3
      t.decimal :a_distance, precision: 13, scale: 3
      t.decimal :d_distance, precision: 13, scale: 3

      t.timestamps
    end
  end
end
