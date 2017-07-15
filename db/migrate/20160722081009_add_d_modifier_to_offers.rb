class AddDModifierToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :d_modifier, :decimal, precision: 7, scale: 4, default: 0.0
  end
end
