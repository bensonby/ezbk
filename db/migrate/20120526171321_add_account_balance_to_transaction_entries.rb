class AddAccountBalanceToTransactionEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :transaction_entries, :account_balance, :decimal, { :scale => 2, :precision => 10 }
  end
end
