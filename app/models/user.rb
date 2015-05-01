class User < ActiveRecord::Base
  acts_as_authentic
  has_many :accounts, :dependent => :destroy
end
