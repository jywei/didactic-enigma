class CreateMatchSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :match_settings do |t|
      t.integer :order_max
      t.integer :match_max
      t.integer :order_pause_point
      t.integer :water
      t.integer :leader_entrance

      t.integer :h_trigger
      t.decimal :h_trigger_percentage
      t.integer :h_total_trigger
      t.decimal :h_total_trigger_percentage
      t.boolean :h_pause
      t.integer :h_pause_point

      t.integer :a_trigger
      t.decimal :a_trigger_percentage
      t.integer :a_total_trigger
      t.decimal :a_total_trigger_percentage
      t.boolean :a_pause
      t.integer :a_pause_point

      t.integer :match_id

      t.timestamps
    end
  end
end
