class Transaction < ActiveRecord::Base
  has_many :transaction_entries, :dependent => :destroy
  attr_accessible :transaction_date, :description, :transaction_entries_attributes
  accepts_nested_attributes_for :transaction_entries, :reject_if => lambda { |a| a[:debit_amount].blank? }, :allow_destroy => true
  validates_presence_of :transaction_date
  validates_presence_of :description
end
