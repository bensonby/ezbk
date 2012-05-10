class AddTransactionDescriptionField < ActiveRecord::Migration
  def change
    add_column :transactions, :description, :string
  end
end
