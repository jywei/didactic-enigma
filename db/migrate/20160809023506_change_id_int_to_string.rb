class ChangeIdIntToString < ActiveRecord::Migration[5.0]
  def up
    change_column :offers, :leader_id, :string
  end

  def down
    change_column :offers, :leader_id, :integer
  end
end
