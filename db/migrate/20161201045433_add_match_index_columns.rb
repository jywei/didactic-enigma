class AddMatchIndexColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :halves, :string
    add_column :offers, :match_leader_id, :integer

    add_index :offers, :book_maker_id
    add_index :offers, :halves
    add_index :offers, :match_leader_id
  end
end
