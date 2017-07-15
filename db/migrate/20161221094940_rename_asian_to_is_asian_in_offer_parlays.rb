class RenameAsianToIsAsianInOfferParlays < ActiveRecord::Migration[5.0]
  def change
    remove_column :offer_parlays, :asian
    add_column :offer_parlays, :type_flag, :string
  end
end
