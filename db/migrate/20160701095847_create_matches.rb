class CreateMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :matches do |t|
      t.time :start_time
      t.boolean :disabled
      t.string :leader
      t.integer :leader_id
      t.integer :hteam_id
      t.integer :ateam_id
      t.integer :category_id
      t.boolean :active

      t.timestamps
    end
  end
end
