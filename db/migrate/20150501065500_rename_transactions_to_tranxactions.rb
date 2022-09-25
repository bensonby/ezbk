class RenameTransactionsToTranxactions < ActiveRecord::Migration[5.0]
  def self.up
    rename_table :transactions, :tranxactions
  end
  def self.down
    rename_table :tranxactions, :transactions
  end
end
