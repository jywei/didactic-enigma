class RemoveStatAndIsRunningFromOfferAsians < ActiveRecord::Migration[5.0]
  def change
    remove_column :offer_asians, :stat, :string
    remove_column :offer_asians, :is_running, :boolean
  end
end
