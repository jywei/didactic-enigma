class CreateMatchResults < ActiveRecord::Migration[5.0]
  def change
    create_table :match_results do |t|
      t.integer :match_id
      t.integer :h_score
      t.integer :a_score
      t.datetime :received_at
      t.datetime :match_time

      t.timestamps
    end
  end
end
