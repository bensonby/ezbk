class Account < ActiveRecord::Base
  before_save :default_values
  attr_accessible :name, :parent_id, :opening_balance
  belongs_to :parent, :class_name => 'Account'
  has_many :children, :class_name => 'Account', :foreign_key => 'parent_id', :dependent => :destroy
  has_many :transaction_entries
  has_many :transactions, :through => :transaction_entries

  def default_values
    self.opening_balance ||= 0
  end
end
