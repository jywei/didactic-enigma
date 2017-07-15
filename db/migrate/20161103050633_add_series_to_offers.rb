class AddSeriesToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :series, :boolean, default: true
  end
end
