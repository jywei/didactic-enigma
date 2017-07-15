class AddIsRunningToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :is_running, :boolean, default: false
  end
end
