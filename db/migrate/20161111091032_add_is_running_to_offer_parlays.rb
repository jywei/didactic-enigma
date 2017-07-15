class AddIsRunningToOfferParlays < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_parlays, :is_running, :boolean, default: false
  end
end
