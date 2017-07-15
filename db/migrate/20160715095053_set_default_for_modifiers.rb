class SetDefaultForModifiers < ActiveRecord::Migration[5.0]
  def change
    change_column :offers, :head, :decimal, precision: 7, scale: 4, default: 0.0
    change_column :offers, :h_odd, :decimal, precision: 7, scale: 4, default: 0.0
    change_column :offers, :a_odd, :decimal, precision: 7, scale: 4, default: 0.0
    change_column :offers, :h_modifier, :decimal, precision: 7, scale: 4, default: 0.0
    change_column :offers, :a_modifier, :decimal, precision: 7, scale: 4, default: 0.0
    change_column :offers, :asian_modifier, :decimal, precision: 7, scale: 4, default: 0.0
  end
end
