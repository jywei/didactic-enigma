class CreateOfferParlays < ActiveRecord::Migration[5.0]
  def change
    create_table :offer_parlays, force: :cascade do |t|
      t.integer :offer_id
      t.string  :name
      t.decimal :h_odd,            precision: 7, scale: 4, default: "0.0"
      t.decimal :a_odd,            precision: 7, scale: 4, default: "0.0"
      t.decimal :d_odd,            precision: 7, scale: 4, default: "0.0"
      t.decimal :h_modifier,       precision: 7, scale: 4, default: "0.0"
      t.decimal :a_modifier,       precision: 7, scale: 4, default: "0.0"
      t.decimal :d_modifier,       precision: 7, scale: 4, default: "0.0"
      t.string  :handicapped_team
      t.decimal :head,             precision: 7, scale: 4, default: "0.0"
      t.integer :asian_proportion
      t.integer :asian_head
      t.decimal :asian_modifier,   precision: 7, scale: 4, default: "0.0"
      t.decimal :water,            precision: 7, scale: 4, default: "0.0"
      t.boolean :flag,             default: true
      t.string  :flat_head
      t.boolean :asian

      t.timestamps
    end
  end
end
