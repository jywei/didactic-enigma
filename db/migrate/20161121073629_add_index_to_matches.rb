class AddIndexToMatches < ActiveRecord::Migration[5.0]
  def change
    add_index :matches, :active
    add_index :matches, :redis_id
    add_index :matches, :category_id

    add_index :log_pushes, :tx_match_id
    add_index :log_pushes, :ot_name
  end
end
