class TransactionEntry < ActiveRecord::Base
  attr_accessible :debit_amount, :transaction_id, :account_id
  after_save :calculate_account_current_balance
  belongs_to :transaction, :foreign_key => 'transaction_id'
  belongs_to :account, :foreign_key => 'account_id', :touch => true
  validates_presence_of :account_id
  validates_presence_of :debit_amount
  validates_numericality_of :debit_amount

  def calculate_account_current_balance
    self.account.save!
  end
end
