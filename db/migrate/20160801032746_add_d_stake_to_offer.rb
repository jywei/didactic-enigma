class AddDStakeToOffer < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :d_stake, :integer, default: 0
  end
end
