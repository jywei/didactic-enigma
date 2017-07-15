class CreateLogErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :log_errors do |t|
      t.string :name
      t.integer :user_id
      t.text :data
      t.string :path
      t.string :uuid
      t.text :backtrace

      t.timestamps
    end
  end
end
