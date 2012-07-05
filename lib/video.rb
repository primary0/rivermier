require 'rubygems'
require 'mongo_mapper'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class Video
  
  include MongoMapper::EmbeddedDocument
    
  key :media_id, String
  key :media_url, String
  key :url, String
  key :display_url, String
  key :expanded_url, String

end