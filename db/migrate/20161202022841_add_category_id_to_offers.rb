class AddCategoryIdToOffers < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :category_id, :integer
  end
end
