class AddBlankTagToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :available, :boolean, :default => false
  end
end
