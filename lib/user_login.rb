# encoding: utf-8
class UserLogin
  include DataMapper::Resource
  include DataMapper::MassAssignmentSecurity
  property :user_id,            Integer, :default => 0
  property :username,           String,  :length  => 0..50
  property :ip_addr,            String,  :length => 0..64
  property :last_login,         DateTime

  def self.logins_last_min(username, ip)
    now = Time.now
    UserLogin.find(username: username, ip: ip).
      where("last_login > ?", now).
      count
  end
end
