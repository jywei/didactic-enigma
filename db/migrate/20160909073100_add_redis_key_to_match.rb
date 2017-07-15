class AddRedisKeyToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :redis_id, :string
  end
end
