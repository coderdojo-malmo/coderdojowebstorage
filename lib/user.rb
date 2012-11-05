require 'dm-rails/mass_assignment_security'
require 'digest'
require 'securerandom'
class User
  include DataMapper::Resource
  include DataMapper::MassAssignmentSecurity
  property :id,                 Serial
  property :username,           String, :length => 3..50
  property :encrypted_password, String, :length => 74
  property :auth_level,         Integer, :default => 0
  property :created_at,         DateTime
  property :updated_at,         DateTime

  validates_uniqueness_of :username
  validates_format_of :username, :as => /^[a-zA-Z0-9]+$/
  validates_length_of :encrypted_password, :min => 74, :max => 74


  attr_accessible :username
  attr_accessor   :password
  attr_reader     :encrypted_password,
                  :auth_level,
                  :created_at,
                  :updated_at

  def password=(pass)
    @password ||= pass
    encrypt_password!
  end

  def encrypt_password!
    self.encrypted_password = User.get_hash(self.password)
  end

  def self.authenticate_by_password(username, password)
    user = User.first :username => username
    salt = user.encrypted_password[0..9]
    if user.encrypted_password.eql?(User.get_hash(password, salt))
      user
    else
      nil
    end
  end


  def self.get_hash(plain, salt = nil)
    salt ||= SecureRandom.hex(5)
    #hash_plain = "#{salt}#{CoderDojoWebStorage::PWSALT}#{plain}"
    #h = Digest::SHA256.hexdigest(hash_plain)
    h = Digest::SHA256.hexdigest("#{salt}#{CoderDojoWebStorage::PWSALT}#{plain}")
    "#{salt}#{h}"
  end

end
