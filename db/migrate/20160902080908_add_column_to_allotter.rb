class AddColumnToAllotter < ActiveRecord::Migration[5.0]
  def change
    add_column :user_allotters, :name_ch, :string
  end
end
