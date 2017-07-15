class CreateLogCloses < ActiveRecord::Migration[5.0]
  def change
    create_table :log_closes do |t|
      t.integer :match_count
      t.text :data

      t.timestamps
    end
  end
end
