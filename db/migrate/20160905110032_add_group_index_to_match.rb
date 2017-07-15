class AddGroupIndexToMatch < ActiveRecord::Migration[5.0]
  def change
    add_index :matches, %i(leader leader_id book_maker_id halves), unique: true, name: 'match_leader_book_maker_index'
  end
end
