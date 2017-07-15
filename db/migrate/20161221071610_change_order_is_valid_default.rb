class ChangeOrderIsValidDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :orders, :is_valid, from: nil, to: true
  end
end
