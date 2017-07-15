class AddIndexToLeaderId < ActiveRecord::Migration[5.0]
  def change
    add_index :matches, :leader
    add_index :matches, :leader_id

    add_index :offers, :leader
    add_index :offers, :leader_id
    add_index :offers, :match_id
  end
end
