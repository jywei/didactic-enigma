class CreateBookMakers < ActiveRecord::Migration[5.0]
  def change
    create_table :book_makers do |t|
      t.string :name
      t.integer :tx_id

      t.timestamps
    end
  end
end
