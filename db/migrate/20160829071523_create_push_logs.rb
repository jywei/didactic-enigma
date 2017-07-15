class CreatePushLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :push_logs do |t|
      t.string :type
      t.string :action
      t.text :log
      t.string :tx_offer_id
      t.integer :tx_match_id
      t.text :data

      t.timestamps
    end
  end
end
