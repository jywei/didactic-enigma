class ChangeOrderResultDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :orders, :settle, false
  end
end
