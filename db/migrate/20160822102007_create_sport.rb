class CreateSport < ActiveRecord::Migration[5.0]
  def change
    create_table :sports, force: true do |t|
      t.integer :leader_spid
      t.string  :name
    end
  end
end
