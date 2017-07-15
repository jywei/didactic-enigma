class AddGroupIndexToOffer < ActiveRecord::Migration[5.0]
  def change
    add_index :offers, %i(head name match_id), unique: true
  end
end
