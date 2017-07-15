class AddWaterToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :d_odd,  :decimal, precision: 7, scale: 4, default: 0.0
    add_column :offers, :h_oppo, :decimal, precision: 7, scale: 4, default: 0.0
    add_column :offers, :a_oppo, :decimal, precision: 7, scale: 4, default: 0.0
    add_column :offers, :d_oppo, :decimal, precision: 7, scale: 4, default: 0.0
    add_column :offers, :water,  :decimal, precision: 7, scale: 4, default: 0.0
  end
end
