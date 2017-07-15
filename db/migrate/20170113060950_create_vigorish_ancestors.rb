class CreateVigorishAncestors < ActiveRecord::Migration[5.0]
  def change
    create_table :vigorish_ancestors do |t|
      t.integer :order_id, null: false
      t.integer :member
      t.integer :agent
      t.integer :general_agent
      t.integer :shareholder
      t.integer :major_shareholder
      t.integer :director
      t.integer :supervisor
      t.integer :moderator
      t.integer :admin
      t.string  :result_flag
      t.string  :sport_name

      t.timestamps
    end
  end
end
