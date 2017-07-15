class AddStakeToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :h_stake, :integer
    add_column :matches, :a_stake, :integer
  end
end
