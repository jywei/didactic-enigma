class AddStuffToOfferPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :offer_positions, :match_id, :integer
    add_column :offer_positions, :offer_name, :string
    remove_column :offer_positions, :offer_id
  end
end
