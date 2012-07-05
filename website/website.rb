require 'rubygems'
require "bundler/setup"
require 'sinatra/base'
require 'rack/mobile-detect'
require 'sinatra/partial'
require 'mongo_mapper'       
require 'uri'
require 'active_support/all'
require 'active_support/inflector'

require File.expand_path(File.dirname(__FILE__) + '/../config/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/trend.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/daily_digest.rb')

class Website < Sinatra::Base
  
  use Rack::MobileDetect  
  register Sinatra::Partial
  
  set :environment, :production   
  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/public'  
  set :partial_underscores, true
  set :partial_template_engine, :erb      
  set :static_cache_control, [:public, {:max_age => 300}]

  # Unless xhr, find mobile request and set mobile partial
  helpers do
    
    # User agent helper
    def get_agent
      if request.xhr? then 
        @layout = false
        @xhr = true
      end
      @layout = case request.env['X_MOBILE_DEVICE']
                when /iPhone|iPod|Android|BlackBerry/ then 
                  true
                else 
                  false
                end
    end
    
    # Abbreviation cap helper
    def format_tag(text)
      if text.length == 3
        if !text.match(/[aeiou]/i)        
          text = text.upcase 
        else
          text = text.titleize if !text.match(/\#/i)          
        end
      elsif text.length < 3
        text = text.upcase
      else
        text = text.titleize if !text.match(/\#/i)
      end
      return text
    end
  end
  
  # Redirect www to base
  before do
    redirect "http://rivermier.com", 301 if request.host =~ /^www/
    get_agent()
  end
  
  # Live Stream
    
  # Default route
  get '/' do
    @trends = Trend.latest_all
    @latest_trend_time = Trend.latest_time
    @tags = @trends.collect{|x|x.gsub(/\#/, "").downcase}.uniq
    @tweets = Tweet.where(:created_at.gte => 12.hours.ago, :tags => {:$in => @tags}, :protected_tweet => false).order(:created_at.desc).limit($TWEETS_PER_PAGE).all
    if @layout
      erb :"mobile/index", :layout => false
    else
      if @xhr
        erb :index, :layout => false
      else
        erb :index        
      end      
    end
  end      
        
  # Standard xhr
  get '/retweets' do
    @retweets = Tweet.latest_retweets
    erb :retweets, :layout => false
  end
  
  get '/photos' do
    @photos = Tweet.latest_photos
    erb :photos, :layout => false
  end
  
  get '/videos' do
    @videos = Tweet.latest_videos
    erb :videos, :layout => false
  end  
  
  # Mobile xhr
  get '/mobile-retweets' do
    @retweets = Tweet.latest_retweets
    erb :"mobile/retweets", :layout => false
  end
  
  get '/mobile-photos' do
    @photos = Tweet.latest_photos
    erb :"mobile/photos", :layout => false
  end  
  
  # Today
  
  get '/today' do
    @daily_digest = DailyDigest.order(:created_at.desc).first
    @retweets = Tweet.where(:retweeted => true, :created_at.gte => 24.hours.ago).order(:created_at.desc).all
    @top_tweets = Tweet.where(:retweeted => true, :following_tweet => true, :created_at.gte => 24.hours.ago, :community_call.ne => true).order(:internal_retweet_count.desc).all.uniq_by{|x|x.user_id}[0..2]
    erb :today, :layout => false
  end
  
  get '/today-photos' do    
    @daily_digest = DailyDigest.order(:created_at.desc).first
    @photos = @daily_digest.photos
    erb :today_photos, :layout => false
  end
  
  get '/today-videos' do    
    @daily_digest = DailyDigest.order(:created_at.desc).first
    @videos = @daily_digest.videos
    erb :today_videos, :layout => false
  end  
  
  get '/today-links' do    
    @daily_digest = DailyDigest.order(:created_at.desc).first
    @links = @daily_digest.web_pages.sort_by{|x|Date.parse(x["created_at"])}.reverse
    erb :today_links, :layout => false
  end  
  
  get '/today-topics' do
    @trends = Trend.daily_trends
    @topic = URI.unescape(params[:topic]).gsub(/\#/, "") if params[:topic]
    @offset = params[:offset].to_i if params[:offset]
    if @topic && @topic != "all"
      ommit_list = File.open(File.expand_path(File.dirname(__FILE__) + '/../reference/ignore.txt')).to_a.collect{|x|x.strip}
      @tags = @topic.split(" ").collect{|x|x.downcase}
      if @tags.length > 1
        @tags.delete_if{|x|ommit_list.include?(x.squeeze(" ").strip)}
      end
      @tweets = Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :protected_tweet => false, :tags => {:$all => @tags}).order(:created_at.desc).offset(@offset).limit($TWEETS_PER_PAGE).all
      @count = Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :protected_tweet => false, :tags => {:$all => @tags}).count
    else
      @tweets = Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :protected_tweet => false, :trend_id.ne => nil).order(:created_at.desc).offset(@offset).limit($TWEETS_PER_PAGE).all
      @count = Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :protected_tweet => false, :trend_id.ne => nil).count
    end
    if @topic || @offset
      erb :today_topics_tweets, :layout => false
    else
      erb :today_topics, :layout => false
    end    
  end
  
  get '/today-people' do
    @daily_digest = DailyDigest.order(:created_at.desc).first
    erb :today_people, :layout => false
  end
  
  # XML Feeds
  
  get '/popular-tweets.xml' do
    @retweets = Tweet.latest_retweets     
    builder :"xml/retweets", :layout => false    
  end  
  
end