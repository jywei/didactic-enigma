class OfferTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :offer_types, force: :cascade do |t|
      t.string :name
      t.string :name_ch

      t.timestamps
    end
  end
end
