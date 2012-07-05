require 'rubygems'
require 'mongo_mapper'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class UserMention
  
  include MongoMapper::EmbeddedDocument
    
  key :user_id, String
  key :screen_name, String
  key :name, String

end