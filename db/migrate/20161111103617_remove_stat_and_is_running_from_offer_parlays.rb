class RemoveStatAndIsRunningFromOfferParlays < ActiveRecord::Migration[5.0]
  def change
    remove_column :offer_parlays, :is_running, :boolean
  end
end
