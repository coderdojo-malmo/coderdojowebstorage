# encoding: utf-8
require 'fileutils'
require 'filemagic'

class UserFile
  ERR_UNABLE_TO_SAVE = 'lyckades inte spara filen ordentligt?'
  ERR_INVALID_FILE = 'ogiltig fil'

  attr_accessor :user,
                :tmpfile,
                :file_name,
                :dir_path,
                :errors

  def initialize file_hash
    self.errors = []
    if (!file_hash ||
        !(self.tmpfile = file_hash[:tempfile]) ||
        !(self.file_name = file_hash[:filename]))
      self.errors << ERR_INVALID_FILE
    end
  end

  def file_name=(name)
    @file_name = name.chomp.gsub(' ', '-').gsub('/', '').gsub('..', '')
  end

  # @todo more validation
  def valid?
    return false unless self.errors.empty?

    unless UserFile.valid_file_ends.include?(File.extname(self.file_name).downcase)
      self.errors << "ogiltig filändelse: #{File.extname(self.file_name)}"
    end

    mime_type = get_mime_type
    unless UserFile.valid_mime_types.include? mime_type
      self.errors << "ogiltig filtyp: #{mime_type}"
    end
    self.errors.empty?
  end

  def save_for user
    return false unless valid?

    self.dir_path = user.file_dir
    FileUtils.mkdir_p(self.dir_path) unless File.directory? self.dir_path
    file_path = File.join(self.dir_path, self.file_name)
    begin
      File.open(file_path, 'w+b') do |f|
        while buffer = self.tmpfile.gets(2048)
          f.write(buffer)
        end
      end
    rescue StandardError => e
      puts "exception writing the uploaded file to disk: #{e}"
      self.errors << ERR_UNABLE_TO_SAVE
      return false
    end
    user.file_uri(self.file_name)
  end

  def self.update(file_path, content)
    begin
      File.open(File.join(file_path), 'wb') do |f|
        f.write(content)
      end
      true
    rescue Exception, e
      puts "exception writing the uploaded file to disk: #{e}"
      self.errors << ERR_UNABLE_TO_SAVE
      false
    end
  end

  def self.sanitize_file_name(file_name)
    file_name.gsub(/^.*(\\|\/)/, '').
              gsub(/[^0-9A-Za-z.\-]/, '_')
  end

  def self.valid_file_name?(file_name)
    file_name.match /^[0-9A-Za-z_.\-]+$/
  end

  private

  def self.valid_mime_types
    %w(text/plain text/html text/xml text/xhtml text/json text/javascript image/jpeg image/png image/gif text/css audio/mpeg)
  end

  def self.valid_file_ends
    %w(.txt .html .xml .json .jpg .jpeg .png .gif .css .js .mp3)
  end

  def get_mime_type
    FileMagic.open(FileMagic::MAGIC_MIME) do |magic|
      magic.file self.tmpfile.path
    end.split(';').first
  end
end
