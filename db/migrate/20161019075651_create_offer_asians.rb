class CreateOfferAsians < ActiveRecord::Migration[5.0]
  def change
    create_table :offer_asians, force: :cascade do |t|
      t.string   "name"
      t.integer  "offer_id"
      t.decimal  "h_odd",                          precision: 7, scale: 4, default: 0.0
      t.decimal  "a_odd",                          precision: 7, scale: 4, default: 0.0
      t.decimal  "h_modifier",                     precision: 7, scale: 4, default: 0.0
      t.decimal  "a_modifier",                     precision: 7, scale: 4, default: 0.0
      t.integer  "asian_proportion"
      t.integer  "asian_head"
      t.decimal  "asian_modifier",                 precision: 7, scale: 4, default: 0.0
      t.integer  "h_stake",                                                default: 0
      t.integer  "a_stake",                                                default: 0
      t.string   "handicapped_team"
      t.string   "asia_format"
      t.string   "orgin_asia_format"
      t.decimal  "water",                          precision: 7, scale: 4, default: 0.0
      t.boolean  "flag",                                                   default: true
      t.string   "flat_head"

      t.timestamps
    end
  end
end
