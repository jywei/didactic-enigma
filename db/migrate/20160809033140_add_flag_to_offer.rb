class AddFlagToOffer < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :flag, :boolean, default: true
  end
end
