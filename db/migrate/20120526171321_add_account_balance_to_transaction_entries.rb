class AddAccountBalanceToTransactionEntries < ActiveRecord::Migration
  def change
    add_column :transaction_entries, :account_balance, :decimal, { :scale => 2, :precision => 10 }
  end
end
