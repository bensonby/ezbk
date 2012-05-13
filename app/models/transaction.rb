class Transaction < ActiveRecord::Base
  has_many :transaction_entries, :dependent => :destroy, :order => "debit_amount DESC"
  has_many :accounts, :through => :transaction_entries
  attr_accessible :transaction_date, :description, :transaction_entries_attributes
  accepts_nested_attributes_for :transaction_entries, :reject_if => lambda { |a| a[:debit_amount].blank? }, :allow_destroy => true
  validates_presence_of :transaction_date
  validates_presence_of :description
  validate :zero_balance
  validate :entries_presence
  after_initialize :init

  def init
    self.transaction_date ||= (DateTime.now - 7.hours).to_date.to_s #I don't expect we will enter the transaction for that day before 7am in the morning..
  end

  def zero_balance
    total_amount = self.transaction_entries.reduce(0) do |sum, t|
      sum + t.debit_amount
    end
    errors.add(:base, "All Transaction Entries must add up to zero") unless total_amount == 0
  end

  def entries_presence
    errors.add(:base, "No transaction entries found (at least two required)") unless self.transaction_entries.length > 0
  end

  def tostring
    self.description + " " + 
    self.transaction_entries.reduce("") do |str, t|
      str + " " + t.account.name + " " + t.debit_amount.to_s
    end
  end
end
