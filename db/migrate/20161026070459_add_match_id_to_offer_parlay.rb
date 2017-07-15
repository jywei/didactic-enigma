class AddMatchIdToOfferParlay < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_parlays, :match_id, :integer
  end
end
