class RenameTransactionsToTranxactions < ActiveRecord::Migration
  def self.up
    rename_table :transactions, :tranxactions
  end
  def self.down
    rename_table :tranxactions, :transactions
  end
end
