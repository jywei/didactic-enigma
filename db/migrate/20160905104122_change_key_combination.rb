class ChangeKeyCombination < ActiveRecord::Migration[5.0]
  def change
    remove_index :matches, %i(leader leader_id halves)
  end
end
