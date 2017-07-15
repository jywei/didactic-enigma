class AddChannelToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :channel, :string, :after => :controller
  end
end
