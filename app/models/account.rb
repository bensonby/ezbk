class Account < ActiveRecord::Base
  include ActiveModel::Dirty
  before_destroy :delete_associated_transactions
  before_save :default_values
  before_save :calculate_current_balance
  after_save :save_original_parent_accounts
  after_save :save_parent_accounts
#  after_save :upon_editing_opening_balance
  #:current_balance
  belongs_to :user
  belongs_to :parent, :class_name => 'Account'
  has_many :children, -> { order(:name) }, :class_name => 'Account', :foreign_key => 'parent_id', :dependent => :destroy
  has_many :transaction_entries
  has_many :tranxactions, :through => :transaction_entries
  scope :of, ->(user) { where(:user_id => user.id) }
  scope :root_accounts, -> { where(:parent_id => nil).order(:name) }
  validates :name, :length => { :minimum => 3 }

  def full_name(prefix = false)
    (self.parent ? self.parent.full_name(true) : "") + self.name + (prefix ? ":" : "")
  end

  def depth
    self.parent ? (1+self.parent.depth) : 0
  end

  def within_depth(depth)
    return self if depth == 0
    self.children.empty? ? self : self.children.map{|acc| acc.within_depth(depth-1) }.flatten
  end

  def descendants
    ([self] + (!self.children.empty? ? self.children.map{|acc| acc.descendants } : [])).flatten
  end

  def upon_editing_opening_balance
    if self.opening_balance_changed?
      self.update_transaction_entry_balances
    end
  end

  def update_transaction_entry_balances()
#    starting_entry ||= self.transaction_entries.
    transaction_entries = self.transaction_entries.all(:joins => :tranxaction, :order => 'tranxactions.transaction_date, tranxactions.id')
    transaction_entries.reduce(self.opening_balance) do |balance, entry|
      entry.account_balance = balance + entry.debit_amount
      entry.save!
      entry.account_balance
    end
  end

  def delete_associated_transactions
    self.tranxactions.each(&:destroy)
  end

  def default_values
    self.opening_balance ||= 0
  end

  def calculate_current_balance
    self.current_balance = self.calculate_own_balance + self.children.reduce(0) do |sum, a|
      sum + a.calculate_current_balance
    end
  end

  def calculate_own_balance
    return self.transaction_entries.reduce(self.opening_balance) do |sum, t|
      sum + t.debit_amount
    end
  end

  def save_original_parent_accounts
    if self.parent_id_changed?
      Account.find(self.parent_id_was).save! if self.parent_id_was
    end
  end

  def save_parent_accounts
    self.parent.save! if self.parent
  end
end
