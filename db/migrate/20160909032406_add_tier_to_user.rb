class AddTierToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tier, :integer, default: 0
    add_column :users, :identity, :string, default: 'normal'
    add_column :users, :fork_id, :integer
  end
end
