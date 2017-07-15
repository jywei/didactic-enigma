class RenameChToDisplayNameInSports < ActiveRecord::Migration[5.0]
  def change
    rename_column :sports, :ch, :display_name
  end
end
