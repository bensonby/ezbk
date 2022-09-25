class AddOpeningBalanceToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :opening_balance, :decimal
  end
end
