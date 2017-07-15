class ChangeDecimalPrecisionInOfferPositions < ActiveRecord::Migration[5.0]
  def change
    change_column :offer_positions, :h_position, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :a_position, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :d_position, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :h_threshold, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :a_threshold, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :d_threshold, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :h_distance, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :a_distance, :decimal, precision: 13, scale: 3
    change_column :offer_positions, :d_distance, :decimal, precision: 13, scale: 3
  end
end
