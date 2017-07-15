class AddChToSports < ActiveRecord::Migration[5.0]
  def change
    add_column :sports, :ch, :string
  end
end
