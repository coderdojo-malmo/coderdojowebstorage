# encoding: utf-8
require 'dm-rails/mass_assignment_security'
require 'bcrypt'
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
  validates_length_of :encrypted_password, :min => 64, :max => 74, :message => 'Du måste ange lösenord'


  attr_accessible :username, :password
  attr_accessor   :password

  attr_reader     :encrypted_password,
                  :auth_level,
                  :created_at,
                  :updated_at

  def file_dir
    File.dirname(__FILE__)+'/../public/u/'+self.username
  end

  def file_path(file_name)
    "/public/u/#{self.username}/#{file_name}"
  end

  def self.authenticate_by_password(username, password)
    puts "will try to authenticate #{username} with pass #{password}"
    user = User.first :username => username
    return nil unless user
    salt = User.salt_from_hash(user.encrypted_password)
    hash_string = User.hash_string(password, salt)
    pass_string = user.encrypted_password[10..user.encrypted_password.size]
    pass = BCrypt::Password.new pass_string
    if pass == hash_string
      user
    else
      nil
    end
  end

  private

  before :valid? do
    if self.password.nil? || self.password.empty?
    else
      encrypt_password!
    end
  end

  def encrypt_password!
    hash_string = User.hash_string(password)
    salt = User.salt_from_hash(hash_string)
    pass = BCrypt::Password.create(hash_string)
    self.encrypted_password = "#{salt}#{pass}"
  end



  def self.hash_string(plain, salt = nil)
    salt ||= SecureRandom.hex(5)
    "#{salt}#{CoderDojoWebStorage::PWSALT}#{plain}"
  end

  def self.new_hash(plain, salt = nil)
    h = User.hash_string(plain, salt)
    salt = User.salt_from_hash(h)
    pass = BCrypt::Password.create(h)
    "#{salt}#{pass}"
  end

  def self.salt_from_hash(h)
    h[0..9]
  end

end
