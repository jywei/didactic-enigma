class CreateUserProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_profiles do |t|
      t.string :nickname
      t.string :note
      t.integer :quota
      t.integer :delay_original
      t.integer :delay_running
      t.integer :parlay
      t.string :status
      t.boolean :accessable

      t.timestamps
    end
  end
end
