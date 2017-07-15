class RemoveGroupIndexInOffers < ActiveRecord::Migration[5.0]
  def change
    remove_index :offers, %i(head name match_id)
  end
end
