class AddFlatToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :flat, :boolean, default: false
    add_index :offers, :flat
  end
end
