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

  validates_uniqueness_of :username,
                          :message => "Användarnamnet finns redan registrerat"
  validates_format_of     :username, :as => /^[a-zA-Z0-9]+$/
  validates_length_of     :encrypted_password, :min => 64, :max => 74,
                          :message => 'Du måste ange lösenord'


  attr_accessible :username, :password
  attr_accessor   :password, :custom_errors

  attr_reader     :encrypted_password,
                  :auth_level,
                  :created_at,
                  :updated_at

  def file_dir
    File.dirname(__FILE__)+'/../public/u/'+self.username
  end

  def files
    #TODO recurse dirs
    Dir.entries(self.file_dir).reject { |f| f[0] == '.' }
  end

  def file_uri(file_name)
    "/u/#{self.username}/#{file_name}"
  end

  def file_edit_uri(file_name)
    "/editor/#{self.username}/#{file_name}"
  end

  def file_path(file_name)
    file = File.expand_path(file_name, self.file_dir)
    # ensure user isn't trying to hack us
    dir = File.expand_path(self.file_dir)
    if file[0, dir.size] != dir
      raise "#{file_name} is trying to access file outside #{dir}"
    end
    file
  end

  def upload_file(file_hash)
    user_file = UserFile.new file_hash
    if uri = user_file.save_for(self)
      uri
    else
      custom_errors = []
      user_file.errors.each do |e|
        custom_errors << e
      end
      false
    end
  end

  # authentication with a very simple layer
  # on top of bcrypt
  def self.authenticate_by_password(username, password)
    user = User.first :username => username
    return false unless user
    salt = User.salt_from_hash(user.encrypted_password)
    hash_string = User.hash_string(password, salt)
    pass_string = user.encrypted_password[10..user.encrypted_password.size]
    pass = BCrypt::Password.new pass_string
    if pass == hash_string
      user
    else
      false
    end
  end

  private

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

  # remember to encrypt the password before validation
  # otherwise, the validation is failed due to checking length
  # on encrypted_password field
  before :valid? do
    if self.password && !self.password.empty?
      encrypt_password!
    end
  end

end
