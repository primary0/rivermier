#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'mongo_mapper'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/user.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/trend.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/daily_digest.rb')

# Website.rb
DailyDigest.ensure_index(:created_at)
Tweet.ensure_index([[:retweeted, 1], [:created_at, -1]])
Tweet.ensure_index([[:retweeted, 1], [:following_tweet, 1], [:created_at, -1], [:community_call, 1]])
Tweet.ensure_index([[:retweeted, 1], [:following_tweet, 1], [:created_at, -1], [:community_call, 1], [:internal_retweet_count, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:created_at, -1], [:protected_tweet, 1], [:tags, 1]])
Tweet.ensure_index([[:following_tweet, 1], [:created_at, -1], [:protected_tweet, 1], [:trend_id, 1]])                

# Tweet.rb
User.ensure_index(:user_id)
Tweet.ensure_index(:tweet_id)
Tweet.ensure_index([[:created_at, -1], [:tags, 1], [:protected_tweet, 1]])                
Tweet.ensure_index(:retweeted)
Tweet.ensure_index([[:retweeted, 1], [:created_at, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:photos, 1], [:protected_tweet, 1]])
Tweet.ensure_index([[:following_tweet, 1], [:photos, 1], [:protected_tweet, 1], [:created_at, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:videos, 1], [:protected_tweet, 1]])
Tweet.ensure_index([[:following_tweet, 1], [:videos, 1], [:protected_tweet, 1], [:created_at, -1]])

# Trend.rb
Trend.ensure_index(:created_at)

# User.rb
Trend.ensure_index(:user_id)

# Analytics
Tweet.ensure_index([[:following_tweet, 1], [:created_at, -1]])

# DB Cleaner   
Tweet.ensure_index([[:retweeted, 1], [:following_tweet, 1], [:created_at, -1]])

# Today crawler
Tweet.ensure_index([[:following_tweet, 1], [:protected_tweet, 1], [:created_at, -1], [:photos, 1], [:retweet_count, -1], [:internal_retweet_count, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:protected_tweet, 1], [:created_at, -1], [:videos, 1], [:retweet_count, -1], [:internal_retweet_count, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:retweeted, 1], [:created_at, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:retweeted, 1], [:created_at, -1], [:internal_retweet_count, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:created_at, -1], [:reply_count, -1]])
Tweet.ensure_index([[:following_tweet, 1], [:created_at, -1], [:retweet_count, -1], [:internal_retweet_count, -1], [:reply_count, -1]])




