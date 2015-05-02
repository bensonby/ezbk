class User < ActiveRecord::Base
  has_secure_password
  acts_as_authentic
  has_many :accounts, :dependent => :destroy
end
