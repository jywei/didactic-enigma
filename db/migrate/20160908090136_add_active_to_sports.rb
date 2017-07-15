class AddActiveToSports < ActiveRecord::Migration[5.0]
  def change
    add_column :sports, :active, :boolean, default: false
  end
end
