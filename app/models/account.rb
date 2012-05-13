class Account < ActiveRecord::Base
  include ActiveModel::Dirty
  before_save :default_values
  before_save :calculate_current_balance
  after_save :save_original_parent_accounts
  after_save :save_parent_accounts
  attr_accessible :name, :parent_id, :opening_balance
  #:current_balance
  belongs_to :parent, :class_name => 'Account'
  has_many :children, :class_name => 'Account', :foreign_key => 'parent_id', :dependent => :destroy
  has_many :transaction_entries
  has_many :transactions, :through => :transaction_entries

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
      Account.find(self.parent_id_was).save!
    end
  end

  def save_parent_accounts
    self.parent.save! if self.parent
  end
end
