class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :tx_name
      t.string :display_name
      t.integer :category_id

      t.timestamps
    end

    add_index :groups, :tx_name
  end
end
