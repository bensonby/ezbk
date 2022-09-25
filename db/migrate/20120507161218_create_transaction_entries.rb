class CreateTransactionEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :transaction_entries do |t|
      t.integer :transaction_id
      t.integer :account_id
      t.decimal :debit_amount
      t.timestamps
    end
  end
end
