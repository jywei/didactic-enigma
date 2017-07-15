class AddScoresToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :h_score, :integer, default: 0
    add_column :matches, :a_score, :integer, default: 0
    add_column :matches, :result, :string
  end
end
