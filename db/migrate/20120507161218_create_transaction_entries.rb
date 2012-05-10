class CreateTransactionEntries < ActiveRecord::Migration
  def change
    create_table :transaction_entries do |t|
      t.integer :transaction_id
      t.integer :account_id
      t.decimal :debit_amount
      t.timestamps
    end
  end
end
