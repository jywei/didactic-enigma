class CreateUserTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|
      t.string :content
      t.string :reason
      t.integer :user_id

      t.timestamps
    end
  end
end
