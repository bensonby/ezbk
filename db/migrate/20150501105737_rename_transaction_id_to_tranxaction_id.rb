class RenameTransactionIdToTranxactionId < ActiveRecord::Migration[5.0]
  def change
    rename_column :transaction_entries, :transaction_id, :tranxaction_id
  end
end
