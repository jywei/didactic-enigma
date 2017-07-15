class AddBookMakerIdToLogPush < ActiveRecord::Migration[5.0]
  def change
    add_column :log_pushes, :book_maker_id, :integer
    add_index :log_pushes, :book_maker_id
  end
end
