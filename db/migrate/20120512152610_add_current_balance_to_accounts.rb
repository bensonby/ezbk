class AddCurrentBalanceToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :current_balance, :decimal, { :scale => 2, :precision => 10 }
  end
end
