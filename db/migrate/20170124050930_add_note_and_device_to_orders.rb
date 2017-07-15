class AddNoteAndDeviceToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :note, :string
    add_column :orders, :device, :string
  end
end
