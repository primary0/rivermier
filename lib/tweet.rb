require 'rubygems'
require 'mongo_mapper'
require 'active_support/all'
require 'twitter'
require 'json'
require 'juggernaut'
require 'net/http'
require 'uri'

require File.expand_path(File.dirname(__FILE__) + '/../config/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/user.rb')
require File.expand_path(File.dirname(__FILE__) + '/trend.rb')
require File.expand_path(File.dirname(__FILE__) + '/photo.rb')
require File.expand_path(File.dirname(__FILE__) + '/url.rb')
require File.expand_path(File.dirname(__FILE__) + '/hashtag.rb')
require File.expand_path(File.dirname(__FILE__) + '/user_mention.rb')
require File.expand_path(File.dirname(__FILE__) + '/video.rb')

class Tweet
  
  include MongoMapper::Document
  
  @queue = :tweets
  
  key :tweet_id, String, :unique => true, :required => true
  key :text, String, :required => true
  key :created_at, Time, :required => true
  key :in_reply_to_status_id, String
  key :retweeted, Boolean, :default => false
  key :retweet_count, Integer, :default => 0
  key :tags, Array, :default => []
  key :retweeter_ids, Array, :default => []
  key :reply_ids, Array, :default => []
  key :internal_retweet_count, Integer, :default => 0
  key :reply_count, Integer, :default => 0
  key :following_tweet, Boolean, :default => false
  key :protected_tweet, Boolean, :default => false
  key :community_call, Boolean, :default => false
  
  belongs_to :trend
  belongs_to :user
  
  many :photos
  many :videos
  many :urls
  many :hashtags
  many :user_mentions
  
  many :replies, :class_name => "Tweet", :in => :reply_ids
  many :retweeters, :class_name => "User", :in => :retweeter_ids
  
  before_destroy :prepare_for_destroy
  
  # Resque task
  def self.perform(item)

    # Is a retweet or not?
    item["retweeted_status"] ? is_retweet = true : is_retweet = false    
    
    # Find existing tweet, user and retweeting user if retweet
    if is_retweet
      user = User.first(:user_id => item["retweeted_status"]["user"]["id_str"])
      tweet = Tweet.first(:tweet_id => item["retweeted_status"]["id_str"])
      retweeting_user = User.first(:user_id => item["user"]["id_str"])
      retweet_count = item["retweeted_status"]["retweet_count"]
    else
      user = User.first(:user_id => item["user"]["id_str"])
      tweet = Tweet.first(:tweet_id => item["id_str"])
      retweet_count = item["retweet_count"]
    end
    
    # Get or create retweeting user if a retweet
    if is_retweet 
      retweeting_user_hash = {
        :user_id => item["user"]["id_str"],
        :name => item["user"]["name"],
        :screen_name => item["user"]["screen_name"],
        :profile_image_url => item["user"]["profile_image_url"],
        :protected_user => item["user"]["protected"]
      }
      item = item["retweeted_status"]
      retweeting_user = User.create_or_update_user(retweeting_user_hash)
      retweeting_user.reload
    end    
    
    # Get or create user
    user_hash = {
      :user_id => item["user"]["id_str"],
      :name => item["user"]["name"],
      :screen_name => item["user"]["screen_name"],
      :profile_image_url => item["user"]["profile_image_url"],
      :protected_user => item["user"]["protected"]
    }
    user = User.create_or_update_user(user_hash)    
    user.reload
    
    # If new tweet
    if !tweet
         
      # Build tweet hash
      tweet_hash = {
        :tweet_id => item["id_str"],
        :text => item["text"],
        :created_at => item["created_at"],
        :in_reply_to_status_id => item["in_reply_to_status_id_str"],
        :retweet_count => item["retweet_count"]
      }
      
      # Collect url entities   
      urls = []
      item["entities"]["urls"].to_a.each do |url|
        if url["expanded_url"].match(/bit\.ly/) || url["expanded_url"].match(/tinyurl/) || url["expanded_url"].match(/goo\.gl/) || url["expanded_url"].match(/is\.gd/) || url["expanded_url"].match(/\/\/t\.co/) || url["expanded_url"].match(/\/\/ow\.ly/)
          expanded_url =  Net::HTTP.get_response(URI.parse(url["expanded_url"]))['location'] || url["expanded_url"]
        else          
          expanded_url = url["expanded_url"]
        end
        new_url = Url.new(:url => url["url"], 
          :display_url => url["display_url"],
          :expanded_url => expanded_url
        )
        urls << new_url
      end       
      
      # Collect photo entities
      # Twitter photos
      photos = []
      item["entities"]["media"].to_a.each do |media|
        new_photo = Photo.new(:media_id => media["media_id"], 
          :media_url => media["media_url"],
          :url => media["url"],
          :display_url => media["display_url"],
          :expanded_url => media["expanded_url"]
        )
        photos << new_photo if media["type"] == "photo"
      end
      
      # Instagram
      urls.each do |url|
        if url["expanded_url"].match(/\/\/instagr\.am/)
          image_url = Net::HTTP.get_response(URI.parse(url["expanded_url"] + 'media/?size=l'))['location']
          if image_url && image_url.match(/jpg\Z/)
            new_photo = Photo.new(:media_url => image_url,
              :url => url["url"],
              :display_url => url["display_url"],
              :expanded_url => image_url
            )
            photos << new_photo            
          end
        end
      end
         
      # Videos
      videos = []      
      urls.each do |url|
        if url["expanded_url"].match(/youtube\.com/) || url["expanded_url"].match(/youtu\.be/)
          media_id = url["expanded_url"].match(/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/).to_a.last if url["expanded_url"].match(/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/)
          if media_id
            new_video = Video.new(:media_id => media_id, 
              :media_url => url["expanded_url"],
              :url => url["url"],
              :display_url => url["display_url"],
              :expanded_url => url["expanded_url"]
            )
            videos << new_video            
          end
        end
      end                  
      
      # Collect hashtag entities  
      hashtags = []
      item["entities"]["hashtags"].to_a.each do |hashtag|
        new_hashtag = Hashtag.new(:text => hashtag["text"])
        hashtags << new_hashtag
      end   
      
      # Collect mention entities   
      user_mentions = []
      item["entities"]["user_mentions"].to_a.each do |user_mention|
        new_user_mention = UserMention.new(:user_id => user_mention["id_str"],
          :screen_name => user_mention["screen_name"],
          :name => user_mention["name"]
        )
        user_mentions << new_user_mention
      end   
      
      # Setup and save tweet
      tweet = Tweet.new(tweet_hash)      
      tweet.user = user
      tweet.retweet_count = retweet_count
      tweet.following_tweet = user.following
      tweet.protected_tweet = user.protected_user
      tweet.photos = photos
      tweet.videos = videos
      tweet.urls = urls if (photos.empty? && videos.empty?)
      tweet.user_mentions = user_mentions
      tweet.hashtags = hashtags 
      tweet.trend = Tweet.assign_trend(tweet.text)
      tweet.tags = Tweet.assign_tags(tweet.text)
      tweet.community_call = Tweet.is_community_call(tweet.text)
      tweet.save
      
      # If a reply, update replies of original tweet  
      tweet.update_replies
      
      # Publish tweet and entities
      tweet.publish
    end

    # If retweet and not retweeted yet
    if tweet && !tweet.retweeted && is_retweet      

      # Add retweeting user to retweeters and update retweet count
      tweet.update_retweeters(retweeting_user)
      
      # Write api retweet count if user is following
      tweet.update_retweet_count(retweet_count)      
      
      # Publish if popular
      tweet.publish_retweet
      
    # If retweet and already retweeted
    elsif tweet && tweet.retweeted && is_retweet
      
      # Write api retweet count if user is following
      tweet.update_retweet_count(retweet_count)      
      
      # Add retweeter to retweeters
      tweet.update_retweeters(retweeting_user)

    # If a tweet by a following
    elsif tweet && tweet.user.following

      # Publish if popular
      tweet.publish_retweet      
    end
  end 
  
  def update_retweet_count(retweet_count)
    if self.user.following
      Tweet.set({:tweet_id => self.tweet_id}, :retweet_count => retweet_count)
    end
  end
  
  # Update replied to tweet's replies and count
  def update_replies
    if self.in_reply_to_status_id
      Tweet.push({:tweet_id => self.in_reply_to_status_id}, :reply_ids => self.id)
      Tweet.increment({:tweet_id => self.in_reply_to_status_id}, :reply_count => 1)
    end
  end  
  
  # Update retweeters and count
  def update_retweeters(retweeting_user)
    Tweet.push({:tweet_id => self.tweet_id}, :retweeter_ids => retweeting_user.id)
    Tweet.increment({:tweet_id => self.tweet_id}, :internal_retweet_count => 1)
  end
  
  # Publish retweet
  def publish_retweet
    
    # If retweeting threshold is matched
    if self.internal_retweet_count >= $POPULAR_THRESHOLD
      
      # Setup auth
      Twitter.configure do |config|
        config.consumer_key = $CONSUMER_KEY
        config.consumer_secret = $CONSUMER_SECRET
        config.oauth_token = $ACCESS_TOKEN
        config.oauth_token_secret = $ACCESS_TOKEN_SECRET
      end

      # Setup broadcast hash    
      response = {
        "tweet_id" => self.tweet_id,
        "created_at" => self.created_at.iso8601,
        "text" => self.text,
        "name" => self.user.name,
        "screen_name" => self.user.screen_name,
        "profile_image_url" => self.user.profile_image_url,
      }

      # Retweet and publish
      Twitter.retweet(self.tweet_id)
      Juggernaut.publish("retweets", response.to_json)
      Tweet.set({:tweet_id => self.tweet_id}, :retweeted => true)
    end    
  end
  
  # Publish tweet and entities to stream
  def publish
    
    # If tweet has trend and user is a following and a non protected user
    if self.trend && self.following_tweet && !self.protected_tweet
      
      # Set up broadcast hash
      response = {
        "tweet_id" => self.tweet_id,
        "created_at" => self.created_at.iso8601,
        "text" => self.text,
        "name" => self.user.name,
        "tags" => self.tags,        
        "screen_name" => self.user.screen_name,
        "profile_image_url" => self.user.profile_image_url, 
      }
      
      # Publish
      Juggernaut.publish("tweets", response.to_json)        
    end
    
    # If a following and a non private user
    if self.following_tweet && !self.protected_tweet
      
      # For all images, setup photo hashes
      self.photos.each do |photo|
        response = {
          "tweet_id" => self.tweet_id,
          "created_at" => self.created_at.iso8601,
          "media_id" => photo.media_id,
          "url" => photo.url,
          "text" => self.text,
          "media_url" => photo.media_url,
          "name" => self.user.name,
          "screen_name" => self.user.screen_name,
          "profile_image_url" => self.user.profile_image_url, 
        }

        # Publish photos
        Juggernaut.publish("photos", response.to_json)
      end
      
      # For all videos, setup video hashes
      self.videos.each do |video|
        response = {
          "tweet_id" => self.tweet_id,
          "created_at" => self.created_at.iso8601,
          "media_id" => video.media_id,
          "url" => video.url,
          "text" => self.text,
          "media_url" => video.media_url,
          "name" => self.user.name,
          "screen_name" => self.user.screen_name,
          "profile_image_url" => self.user.profile_image_url, 
        }

        # Publish videos
        Juggernaut.publish("videos", response.to_json)
      end            
    end
         
  end
  
  # Get words to be assigned for tweet's text
  def self.assign_tags(text)
    
    ommit_list = File.open(File.expand_path(File.dirname(__FILE__) + '/../reference/ignore.txt')).to_a.collect{|x|x.strip}
    
    text = text.split(" ")
    text = text.collect{|x|x.downcase.gsub(/@\w+/, "").gsub(/\A\d+\Z/, "").gsub(/\bhttp\S\b/, "").gsub(/[^a-zA-Z0-9-]/, "").squeeze(" ").strip}    
    text.delete_if{|x|ommit_list.include?(x)}    
    return text.uniq.sort
  end  
  
  # Get a trend to be assigned for tweet's text
  def self.assign_trend(text)
    result = nil
    
    # For latest trends
    Trend.latest.each do |trend|
      trends = [trend.phrases + trend.hashtags].flatten.compact.sort.uniq.join("|").gsub(/\#/, "")
      
      # If text matches trend, break and return trend object
      if text.match(/(?:\b|\#)(#{trends})\b/i)
        result = trend
        break        
      end
    end        
    return result
  end
  
  # Check for community calls
  def self.is_community_call(text)
    if (text.match(/blood/i) && text.match(/call/i)) || (text.match(/blood/i) && text.match(/need/i)) || (text.match(/blood/i) && text.match(/urgent/i)) || (text.match(/needed/i) && text.match(/pls/i) && text.match(/call/i))
      return true
    else
      return false
    end    
  end  
  
  # Get latest retweets
  def self.latest_retweets
    return Tweet.where(:retweeted => true).order(:created_at.desc).limit($TWEETS_PER_PAGE).all
  end
  
  # Get latest photos
  def self.latest_photos
    return Tweet.where(:following_tweet => true, :photos.ne => [], :protected_tweet => false).order(:created_at.desc).limit($PHOTOS_PER_PAGE).all
  end
  
  # Get latest videos
  def self.latest_videos
    return Tweet.where(:following_tweet => true, :videos.ne => [], :protected_tweet => false).order(:created_at.desc).limit($VIDEOS_PER_PAGE).all
  end  
  
  # Clear associations and reset replies and retweets before destroy
  def prepare_for_destroy
    self.photos.clear
    self.hashtags.clear
    self.user_mentions.clear
    self.urls.clear
    if self.in_reply_to_status_id
      Tweet.pull({:tweet_id => self.in_reply_to_status_id}, :reply_ids => self.id)
      Tweet.decrement({:tweet_id => self.in_reply_to_status_id}, :reply_count => 1)
    end
  end
  
end
