class StaticFile
  include DataMapper::Resource
  property :id,           Serial
  property :title,        String
  property :content,      Text
  property :content_type, String
  property :path,         String
  property :created_at,   DateTime
  property :updated_at,   DateTime
end
