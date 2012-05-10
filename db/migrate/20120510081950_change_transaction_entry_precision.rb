class ChangeTransactionEntryPrecision < ActiveRecord::Migration
  def up
    change_column :transaction_entries, :debit_amount, :decimal, { :scale => 2, :precision => 10 }
  end

  def down
    change_column :transaction_entries, :debit_amount, :decimal
  end
end
