class AddTxMatchAndOfferToLog < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :tx_offer, :text
    add_column :log_pushes, :tx_match, :text
  end
end
