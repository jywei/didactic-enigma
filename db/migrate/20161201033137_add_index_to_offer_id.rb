class AddIndexToOfferId < ActiveRecord::Migration[5.0]
  def change
    add_index :offer_asians, :offer_id
    add_index :offer_parlays, :offer_id
  end
end
