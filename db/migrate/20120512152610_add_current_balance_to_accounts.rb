class AddCurrentBalanceToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :current_balance, :decimal, { :scale => 2, :precision => 10 }
  end
end
