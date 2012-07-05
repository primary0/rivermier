require 'rubygems'
require 'mongo_mapper'
require 'active_support/all'                             

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class User
  
  include MongoMapper::Document  
  
  @queue = :users
  
  key :user_id, String, :unique => true, :required => true
  key :name, String
  key :screen_name, String
  key :profile_image_url, String
  key :protected_user, Boolean, :default => false
  key :following, Boolean, :default => false
  
  many :tweets do
    def today
      where(:created_at.gte => 24.hours.ago)
    end
  end
  
  validates_presence_of :user_id
  
  def self.perform(user_id)
    User.create(:user_id => user_id.to_s)
  end
  
  def self.create_or_update_user(user_hash)
    user = User.first(:user_id => user_hash[:user_id])    
    if user
      user.name = user_hash[:name]
      user.screen_name = user_hash[:screen_name]
      user.profile_image_url = user_hash[:profile_image_url]
      user.protected_user = user_hash[:protected_user]
      user.save      
    else
      user = User.new
      user.user_id = user_hash[:user_id]
      user.name = user_hash[:name]
      user.screen_name = user_hash[:screen_name]
      user.profile_image_url = user_hash[:profile_image_url]
      user.protected_user = user_hash[:protected_user]      
      user.save
    end
    user.reload
    return user
  end

end