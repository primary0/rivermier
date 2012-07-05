require 'rubygems'
require 'mongo_mapper'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class Url
  
  include MongoMapper::EmbeddedDocument
    
  key :url, String
  key :display_url, String
  key :expanded_url, String

end