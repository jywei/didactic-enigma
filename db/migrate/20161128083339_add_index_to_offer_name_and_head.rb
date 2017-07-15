class AddIndexToOfferNameAndHead < ActiveRecord::Migration[5.0]
  def change
    add_index :offers, :name
    add_index :offers, :head
  end
end
