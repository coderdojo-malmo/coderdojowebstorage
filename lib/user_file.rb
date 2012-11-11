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
    filemagic = FileMagic.new(FileMagic::MAGIC_MIME)
    mime = filemagic.file(self.tmpfile.path)
    spl = mime.split(";")
    mime_type = spl[0]
    filemagic.close
    unless UserFile.valid_mime_types.include? mime_type
      self.errors << "ogiltig filtyp"
    end
    self.errors.empty?
  end


  def save_for user 
    return false unless valid?

    self.dir_path = user.file_dir
    FileUtils.mkdir_p(self.dir_path) unless File.directory? self.dir_path
    file_path = File.join(self.dir_path, self.file_name)
    while buffer = tmpfile.read(65536)
      begin
        File.open(File.join(file_path), "wb") do |f|
          f.write(buffer)
        end
      rescue Exception, e
        puts "exception writing the uploaded file to disk: #{e}"
        self.errors << "lyckades inte spara filen ordentligt?"
        return false
      end
    end
    return user.file_uri(self.file_name)
  end

  private

  def self.valid_mime_types
    [
      "text/plain", "text/html", "text/xml", "text/xhtml", "text/json",
      "image/jpeg", "image/png", "image/gif"
    ]
  end

end
