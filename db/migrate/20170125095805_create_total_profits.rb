class CreateTotalProfits < ActiveRecord::Migration[5.0]
  def change
    create_table :total_profits do |t|
      t.integer :order_id, null: false
      t.integer :user_id
      t.decimal :member, precision: 12, scale: 3
      t.decimal :agent, precision: 12, scale: 3
      t.decimal :general_agent, precision: 12, scale: 3
      t.decimal :shareholder, precision: 12, scale: 3
      t.decimal :major_shareholder, precision: 12, scale: 3
      t.decimal :director, precision: 12, scale: 3
      t.decimal :supervisor, precision: 12, scale: 3
      t.decimal :moderator, precision: 12, scale: 3
      t.decimal :admin, precision: 12, scale: 3
      t.decimal :unsplit_amount, precision: 12, scale: 3
      t.string  :result_flag
      t.string  :sport_name

      t.timestamps
    end
  end
end
