class UserSession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  before_destroy :reset_persistence_token
  before_create  :reset_persistence_token

  def reset_persistence_token
    record.reset_persistence_token
  end 

  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end

end
