class AddIndexToTeam < ActiveRecord::Migration[5.0]
  def change
    add_index :teams, :tx_id
  end
end
