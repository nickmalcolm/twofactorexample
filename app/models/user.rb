class User < ActiveRecord::Base

  has_secure_password

  def self.authenticate(email, password)
    self.find_by(email: email).try(:authenticate, password)
  end

end
