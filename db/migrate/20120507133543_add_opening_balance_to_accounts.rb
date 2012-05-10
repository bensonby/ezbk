class AddOpeningBalanceToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :opening_balance, :decimal
  end
end
