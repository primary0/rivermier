class Tweet < ActiveRecord::Base

  attr_accessible :tweet_id, :text, :tags, :in_reply_to_status_id, :retweeted, :retweet_count, :community_call, :created_at  
  belongs_to :user
  has_and_belongs_to_many :photos
  has_and_belongs_to_many :videos
  has_and_belongs_to_many :urls
  has_many :replies, :class_name => "Tweet", :foreign_key => "in_reply_to_status_id"  
  belongs_to :in_reply_to_status, :class_name => "Tweet"
  validates_presence_of :user_id
  validates_uniqueness_of :tweet_id
  default_scope order: 'tweets.created_at DESC'
  before_destroy :destroy_entities
  def as_json(options = {})
    { id: self.id,
      tweet_id: self.tweet_id,
      text: self.text,
      retweet_count: self.retweet_count,
      created_at: self.created_at,
      user: self.user
    }
  end    

  def self.perform(item)
    item["retweeted_status"] ? is_retweet = true : is_retweet = false    

    if is_retweet
      user = User.where(user_id: item["retweeted_status"]["user"]["id_str"]).first
      tweet = Tweet.where(tweet_id: item["retweeted_status"]["id_str"]).first
      retweeting_user = User.where(user_id: item["user"]["id_str"]).first
    else
      user = User.where(user_id: item["user"]["id_str"]).first
      tweet = Tweet.where(tweet_id: item["id_str"]).first
    end

    if is_retweet 
      retweeting_user_hash = {
        user_id: item["user"]["id_str"],
        name: item["user"]["name"],
        screen_name: item["user"]["screen_name"],
        profile_image_url: item["user"]["profile_image_url"],
        protected_user: item["user"]["protected"]
      }
      item = item["retweeted_status"]
      retweeting_user = User.create_or_update_user(retweeting_user_hash)
    end    

    user_hash = {
      user_id: item["user"]["id_str"],
      name: item["user"]["name"],
      screen_name: item["user"]["screen_name"],
      profile_image_url: item["user"]["profile_image_url"],
      protected_user: item["user"]["protected"]
    }
    user = User.create_or_update_user(user_hash)    
    
    if tweet
      tweet.update_attribute(:retweet_count, tweet.retweet_count + 1) if is_retweet
      tweet.publish_retweet if !tweet.retweeted && is_retweet

    else
      tweet_hash = {
        tweet_id: item["id_str"],
        text: item["text"],
        created_at: item["created_at"],        
      }
      in_reply_to_status = Tweet.where(tweet_id: item["in_reply_to_status_id_str"]).first if item["in_reply_to_status_id_str"]
      tweet = Tweet.new(tweet_hash)      
      tweet.user = user
      tweet.tags = Tweet.assign_tags(tweet.text)
      tweet.in_reply_to_status = in_reply_to_status if in_reply_to_status
      tweet.community_call = Tweet.is_community_call(tweet.text)
      tweet.save
        
      item["entities"]["urls"].to_a.each do |url|        
        begin
          agent = Mechanize.new
          page = agent.get(url["expanded_url"])
          expanded_url = page.uri.to_s
        rescue => e
          expanded_url = url["expanded_url"]
        end
        #if url["expanded_url"].match(/bit\.ly/) || url["expanded_url"].match(/tinyurl/) || url["expanded_url"].match(/goo\.gl/#) || url["expanded_url"].match(/is\.gd/) || url["expanded_url"].match(/\/\/t\.co/) || url["expanded_url"].match(/\/#\/ow\.ly/)
        #  expanded_url =  Net::HTTP.get_response(URI.parse(url["expanded_url"]))['location'] || url["expanded_url"]
        #else          
        #  expanded_url = url["expanded_url"]
        #end
        new_url = Url.find_or_create_by_url(url: expanded_url)
        new_url.delay.perform
        tweet.urls << new_url
      end       
      
      item["entities"]["media"].to_a.each do |media|
        if media["type"] == "photo"
          new_photo = Photo.find_or_create_by_url(url: media["media_url"])
          tweet.photos << new_photo
        end
      end
      
      tweet.urls.each do |url|
        if url.url && url.url.match(/\/\/instagram\.com/)
          image_url = Net::HTTP.get_response(URI.parse(url.url + 'media/?size=l'))['location']
          if image_url && image_url.match(/jpg\Z/)
            new_photo = Photo.find_or_create_by_url(url: image_url)
            tweet.photos << new_photo            
          end
        end
      end
 
      tweet.urls.each do |url|
        if url.url && (url.url.match(/youtube\.com/) || url.url.match(/youtu\.be/))
          media_id = url.url.match(/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/).to_a.last if url.url.match(/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/)
          if media_id
            new_video = Video.find_or_create_by_url_and_media_id(url: url.url, media_id: media_id)
            tweet.videos << new_video            
          end
        end
      end
    end 	
  end
  
  def publish_retweet
    return if self.retweet_count < ENV['POPULAR_THRESHOLD'].to_i
    Twitter.retweet(self.tweet_id)    
    self.update_attribute(:retweeted, true)
  end
    
  def self.assign_tags(text)    
    ommit_list = File.open("#{Rails.root}/lib/ignore.txt").to_a.collect{|x|x.strip}    
    text = text.split(" ")
    text = text.collect{|x|x.downcase.gsub(/@\w+/, "").gsub(/\A\d+\Z/, "").gsub(/\bhttp\S\b/, "").gsub(/[^a-zA-Z0-9-]/, "").squeeze(" ").strip}    
    text.delete_if{|x|ommit_list.include?(x)}    
    return text.uniq.sort.join(",")
  end  
  
  def self.is_community_call(text)
    if (text.match(/blood/i) && text.match(/call/i)) || (text.match(/blood/i) && text.match(/need/i)) || (text.match(/blood/i) && text.match(/urgent/i)) || (text.match(/needed/i) && text.match(/pls/i) && text.match(/call/i))
      return true
    else
      return false
    end    
  end  
  
  def self.latest_retweets
    return Tweet.where(retweeted: true).order('created_at DESC').limit(ENV['TWEETS_PER_PAGE']).all
  end
  
  def self.latest_photos
    return Tweet.includes(:user, :photos).where(photos[:id].not_eq(nil), users[:protected_user].eq(false), users[:following].eq(true)).order('created_at DESC').limit(ENV['PHOTOS_PER_PAGE']).all
  end

  def self.latest_videos
    return Tweet.includes(:user, :videos).where(videos[:id].not_eq(nil), users[:protected_user].eq(false), users[:following].eq(true)).order('created_at DESC').limit(ENV['VIDEOS_PER_PAGE']).all
  end  

  private

  def destroy_entities
    self.photos.each do |entity|
      entity.destroy if entity.tweets.length <= 1
    end
    self.urls.each do |entity|
      entity.destroy if entity.tweets.length <= 1
    end
    self.videos.each do |entity|
      entity.destroy if entity.tweets.length <= 1
    end
  end

end
