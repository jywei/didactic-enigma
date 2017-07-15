class CreateOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :offers do |t|
      t.string  :name
      t.decimal :h_odd
      t.decimal :a_odd
      t.decimal :h_modifier
      t.decimal :a_modifier
      t.string  :handicapped_team
      t.decimal :head
      t.integer :asian_proportion
      t.integer :asian_modifier
      t.string  :leader
      t.integer :leader_id
      t.boolean :disabled
      t.integer :book_maker_id
      t.integer :match_id

      t.timestamps
    end
  end
end
