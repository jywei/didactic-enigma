class AddDefaultToStake < ActiveRecord::Migration[5.0]
  def change
    change_column :matches, :active, :boolean, default: false
    change_column :offers, :h_stake, :integer, default: 0
    change_column :offers, :a_stake, :integer, default: 0
  end
end
