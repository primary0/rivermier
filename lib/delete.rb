require 'rubygems'
require 'juggernaut'
require 'json'

require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class Delete
    
  @queue = :deletes
    
  def self.perform(tweet_id)
    tweet = Tweet.where(:tweet_id => tweet_id).first
    if tweet 
      tweet.delete
      Juggernaut.publish("deletes", {"tweet_id" => tweet_id}.to_json)    
    end
  end
end