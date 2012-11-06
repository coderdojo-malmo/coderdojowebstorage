# encoding: utf-8
class StaticFile
  include DataMapper::Resource
  property :id,           Serial
  property :user_id,      Integer
  property :title,        String
  property :content,      Text
  property :content_type, String
  property :path,         String
  property :created_at,   DateTime
  property :updated_at,   DateTime
end
