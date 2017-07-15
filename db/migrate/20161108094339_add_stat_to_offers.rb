class AddStatToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :stat, :string
  end
end
