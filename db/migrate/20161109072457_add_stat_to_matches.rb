class AddStatToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :stat, :string
  end
end
