class UserAncestors < ActiveRecord::Migration[5.0]
  def change
    create_table :user_ancestors do |t|
      t.integer :user_id, null: false
      t.integer :agent
      t.integer :general_agent
      t.integer :shareholder
      t.integer :major_shareholder
      t.integer :director
      t.integer :supervisor
      t.integer :moderator
      t.integer :admin

      t.timestamps
    end
  end
end
