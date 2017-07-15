class AddBankIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :bank_id, :integer
  end
end
