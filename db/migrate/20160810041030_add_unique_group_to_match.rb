class AddUniqueGroupToMatch < ActiveRecord::Migration[5.0]
  def change
    add_index :matches, %i(leader leader_id halves), unique: true
  end
end
