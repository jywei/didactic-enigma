class AddBookMakerIdToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :book_maker_id, :integer
    add_index :matches, :book_maker_id
  end
end
