# encoding: utf-8
require 'fileutils'
require 'filemagic'
class UserFile
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
      self.errors << "ogiltig fil"
    end
  end


  def file_name=(name)
    @file_name = name.chomp.gsub(" ", "-").gsub("/","").gsub("..","")
  end


  # @todo more validation
  def valid?
    return false unless self.errors.empty?

    unless UserFile.valid_file_ends.include?(File.extname(self.file_name).downcase)
      self.errors << "ogiltig filändelse: #{File.extname(self.file_name)}"
    end

    filemagic = FileMagic.new(FileMagic::MAGIC_MIME)
    mime = filemagic.file(self.tmpfile.path)
    spl = mime.split(";")
    mime_type = spl[0]
    filemagic.close
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
      File.open(file_path, "w+b") do |f|
        while buffer = self.tmpfile.gets(2048)
          f.write(buffer)
        end
      end
    rescue StandardError => e
      puts "exception writing the uploaded file to disk: #{e}"
      self.errors << "lyckades inte spara filen ordentligt?"
      return false
    end
    return user.file_uri(self.file_name)
  end

  def self.update(file_path, content)
    begin
      File.open(File.join(file_path), "wb") do |f|
        f.write(content)
      end
    rescue Exception, e
      puts "exception writing the uploaded file to disk: #{e}"
      self.errors << "lyckades inte spara filen ordentligt?"
      return false
    end
    true
  end

  def self.sanitize_file_name(file_name)
    file_name.gsub(/^.*(\\|\/)/, '').
              gsub(/[^0-9A-Za-z.\-]/, '_')
  end

  def self.valid_file_name?(file_name)
    (file_name.match(/^[0-9A-Za-z.\-]+$/)) ? true : false
  end

  private

  def self.valid_mime_types
    [
      "text/plain", "text/html", "text/xml", "text/xhtml", "text/json",
      "image/jpeg", "image/png", "image/gif", "text/css",
    ]
  end

  def self.valid_file_ends
    [
      ".txt", ".html", ".xml", ".json",
      ".jpg", ".jpeg", ".png", ".gif", ".css"
    ]
  end

end
