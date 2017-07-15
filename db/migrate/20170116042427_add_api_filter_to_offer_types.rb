class AddApiFilterToOfferTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_types, :api_filter, :boolean
  end
end
