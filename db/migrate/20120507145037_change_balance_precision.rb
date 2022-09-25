class ChangeBalancePrecision < ActiveRecord::Migration[5.0]
  def up
    change_column :accounts, :opening_balance, :decimal, { :scale => 2, :precision => 10 }
  end

  def down
    change_column :accounts, :opening_balance, :decimal
  end
end
