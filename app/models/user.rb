class User < ActiveRecord::Base

  attr_accessible :user_id, :name, :screen_name, :profile_image_url, :protected_user, :following
  validates_uniqueness_of :user_id  
  has_many :tweets
  before_destroy :check_for_existing_tweets

  def self.perform(user_id)
    User.create(user_id: user_id.to_s)
  end
  
  def self.create_or_update_user(user_hash)
    user = User.where(user_id: user_hash[:user_id]).first
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
    return user
  end

  def check_for_existing_tweets
    !self.tweets
  end
end