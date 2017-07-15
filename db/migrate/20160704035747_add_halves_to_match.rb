class AddHalvesToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :halves, :string
  end
end
