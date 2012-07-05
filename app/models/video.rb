class Video < ActiveRecord::Base
	attr_accessible :url, :media_id
  has_and_belongs_to_many :tweets
  validates_uniqueness_of :url, :media_id
  validates_presence_of :url, :media_id
  default_scope order: 'videos.created_at DESC'
  def as_json(options = {})
    { id: self.id,
      url: self.url,
      media_id: self.media_id,
      tweet: self.top_tweet
    }
  end

  def top_tweet
  	self.tweets.order('retweet_count DESC').first
  end
end
