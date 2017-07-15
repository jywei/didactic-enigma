class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :name_cn
      t.integer :category_id
      t.integer :tx_id

      t.timestamps
    end
  end
end
