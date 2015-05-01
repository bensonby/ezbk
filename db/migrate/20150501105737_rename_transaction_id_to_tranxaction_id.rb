class RenameTransactionIdToTranxactionId < ActiveRecord::Migration
  def change
    rename_column :transaction_entries, :transaction_id, :tranxaction_id
  end
end
