class AddIncomingUpdateToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :incoming_request, :text
  end
end
