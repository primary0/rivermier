require 'rubygems'
require 'mongo_mapper'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class Hashtag
  
  include MongoMapper::EmbeddedDocument
    
  key :text, String

end