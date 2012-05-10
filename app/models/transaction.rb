class Transaction < ActiveRecord::Base
  has_many :transaction_entries, :dependent => :destroy, :order => "debit_amount DESC"
  has_many :accounts, :through => :transaction_entries
  attr_accessible :transaction_date, :description, :transaction_entries_attributes
  accepts_nested_attributes_for :transaction_entries, :reject_if => lambda { |a| a[:debit_amount].blank? }, :allow_destroy => true
  validates_presence_of :transaction_date
  validates_presence_of :description
end
