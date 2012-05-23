class User < ActiveRecord::Base
  attr_accessible :password, :password_confirmation
  acts_as_authentic
  attr_accessible :email, :login
  has_many :accounts, :dependent => :destroy
end
