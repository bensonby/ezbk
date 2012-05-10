class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
  end
end
