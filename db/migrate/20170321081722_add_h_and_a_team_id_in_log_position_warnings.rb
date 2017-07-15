class AddHAndATeamIdInLogPositionWarnings < ActiveRecord::Migration[5.0]
  def change
    add_column :log_position_warnings, :h_team_id, :integer
    add_column :log_position_warnings, :a_team_id, :integer
  end
end
