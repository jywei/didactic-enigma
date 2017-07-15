class AddIsRunningToOfferAsians < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_asians, :is_running, :boolean, default: false
  end
end
