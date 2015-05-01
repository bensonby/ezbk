class TransactionEntry < ActiveRecord::Base
  after_destroy :calculate_account_current_balance
  after_save :calculate_account_current_balance
  belongs_to :tranxaction, :foreign_key => 'tranxaction_id'
  belongs_to :account, :foreign_key => 'account_id', :touch => true
  validates_presence_of :account_id
  validates_presence_of :debit_amount
  validates_numericality_of :debit_amount

  def calculate_account_current_balance
    self.account.save!
  end

  def account_balance=(value)
    self.account_balance = value
  end
end
