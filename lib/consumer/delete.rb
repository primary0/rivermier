class Delete
  def self.perform(tweet_id)
    tweet = Tweet.where(tweet_id: tweet_id).first
    if tweet 
      tweet.destroy
    end
  end
end
