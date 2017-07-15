class ChangeToGroupIndexForOffers < ActiveRecord::Migration[5.0]
  def change
    remove_index :offers, :head
    remove_index :offers, :name
    remove_index :offers, :book_maker_id
    remove_index :offers, :halves
    remove_index :offers, :match_leader_id
    add_index :offers, %i(head name book_maker_id halves match_leader_id), unique: true, name: 'unique_offer_index'
  end
end
