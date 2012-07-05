class Photo < ActiveRecord::Base
	attr_accessible :url
  has_and_belongs_to_many :tweets
  validates_uniqueness_of :url
  validates_presence_of :url
  default_scope order: 'photos.created_at DESC'
  def as_json(options = {})
    { id: self.id,
      url: self.url,
      display_url: display_url,
      tweet: self.top_tweet
    }
  end

  def top_tweet
  	self.tweets.order('retweet_count DESC').first
  end

  def display_url
    self.top_tweet.urls.first ? self.top_tweet.urls.first.url : self.url
  end
end
