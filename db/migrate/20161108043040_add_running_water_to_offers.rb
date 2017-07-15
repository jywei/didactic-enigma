class AddRunningWaterToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :running_water, :decimal, precision: 6, scale: 3, default: 0.02
  end
end
