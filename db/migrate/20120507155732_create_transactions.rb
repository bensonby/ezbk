class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :transaction_date
      t.timestamps
    end
  end
end
