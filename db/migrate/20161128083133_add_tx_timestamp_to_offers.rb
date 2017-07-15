class AddTxTimestampToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :leader_timestamp, :string
  end
end
