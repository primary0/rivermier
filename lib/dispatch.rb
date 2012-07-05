require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/delete.rb')

class Dispatch
  
  @queue = :dispatch  
      
  def self.perform(item)
    
    if (item && item["retweeted_status"] && item["user"]["id_str"] != $LOGGED_IN_USER_ID && item["retweeted_status"]["user"]["id_str"] != $LOGGED_IN_USER_ID) || (item && item["text"] && item["user"]["id_str"] != $LOGGED_IN_USER_ID)
      Resque.enqueue(Tweet, item)
    end
        
    if item && item["delete"] && item["delete"]["status"] && item["delete"]["status"]["id_str"]
      Resque.enqueue(Delete, item["delete"]["status"]["id_str"])
    end
  end    
end