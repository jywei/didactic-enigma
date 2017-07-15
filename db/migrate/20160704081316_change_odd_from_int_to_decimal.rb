class ChangeOddFromIntToDecimal < ActiveRecord::Migration[5.0]
  def change
    change_column :offers, :h_odd, :decimal, scale: 4, precision: 6
    change_column :offers, :a_odd, :decimal, scale: 4, precision: 6
    change_column :offers, :h_modifier, :decimal, scale: 4, precision: 6
    change_column :offers, :a_modifier, :decimal, scale: 4, precision: 6
    change_column :offers, :head, :decimal, scale: 4, precision: 6
  end
end
