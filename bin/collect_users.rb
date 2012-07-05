#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require File.expand_path(File.dirname(__FILE__) + '/../config/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/user.rb')

Twitter.configure do |config|
  config.consumer_key = $CONSUMER_KEY
  config.consumer_secret = $CONSUMER_SECRET
  config.oauth_token = $ACCESS_TOKEN
  config.oauth_token_secret = $ACCESS_TOKEN_SECRET
end

user_ids = Twitter.friend_ids.collection
user_ids = user_ids.map{|x|x.to_s}
user_ids.each do |user_id|
  user = User.where(:user_id => user_id).first  
  unless user
    puts "New user created"            
    User.create(:user_id => user_id.to_s, :following => true)
  else
    if user.following == false
      puts "FOLLOWING: #{user.screen_name}"
      User.set({:user_id => user_id.to_s}, :following => true)      
    end
  end
end     

users = User.all
users.each do |user|
  if !user_ids.include?(user.user_id) && user.following == true
    puts "No longer following #{user.screen_name}"
    User.set({:user_id => user.user_id}, :following => false)
  end
end