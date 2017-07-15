class AddMoreOfferSpecsToOfferTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_types, :offer_name, :string
    add_column :offer_types, :running, :boolean
    add_column :offer_types, :parlay, :boolean
  end
end
