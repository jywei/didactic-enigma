class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.datetime :time
      t.string :ip
      t.integer :amount
      t.string :result
      t.integer :user_id

      t.timestamps
    end
  end
end
