class AddStatToOfferAsians < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_asians, :stat, :string
  end
end
