class Tranxaction < ActiveRecord::Base
  self.per_page = 20 #20 transaction entries, not 20 transactions
  has_many :transaction_entries, -> { order(debit_amount: :desc) }, :dependent => :destroy
  has_many :accounts, :through => :transaction_entries
  accepts_nested_attributes_for :transaction_entries, :reject_if => lambda { |a| a[:debit_amount].blank? }, :allow_destroy => true
  validates_presence_of :transaction_date
  validates_presence_of :description
  validate :zero_balance
  validate :entries_presence
  after_initialize :init
  scope :of_user, lambda { |user| joins(:transaction_entries => :account).where(:accounts => {:user_id => user.id}) }

  def init
    self.transaction_date ||= (DateTime.now - 7.hours).to_date.to_s #I don't expect we will enter the transaction for a day before 7am in the morning of that same day
  rescue ActiveModel::MissingAttributeError #due to partial select in account controller -> report
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
