class AddStakesToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :h_stake, :integer
    add_column :offers, :a_stake, :integer
    remove_column :matches, :h_stake
    remove_column :matches, :a_stake
  end
end
