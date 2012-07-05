#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'active_support/all'
require 'resque'
require 'pp'

require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/daily_digest.rb')

$INTERESTING_THRESHOLD = 3
$INTERESTING_THRESHOLD_HIGH = 7
$INTERESTING_THRESHOLD_LOW = 1

# Collect interesting photos
puts "Collecting photos"
$pop_photos = Tweet.where(:following_tweet => true, :protected_tweet => false, :created_at.gte => 24.hours.ago, :photos.ne => [], :$or => [{:retweet_count => {:$gte => $INTERESTING_THRESHOLD}}, {:internal_retweet_count => {:$gte => $INTERESTING_THRESHOLD}}, {:reply_count => {:$gte => $INTERESTING_THRESHOLD}}]).order(:created_at.desc).all
$pop_photos = $pop_photos.uniq_by{|x|x.photos.first.expanded_url}

# Collect interesting videos
puts "Collecting videos"
$pop_videos = Tweet.where(:following_tweet => true, :protected_tweet => false, :created_at.gte => 24.hours.ago, :videos.ne => [], :$or => [{:retweet_count => {:$gte => $INTERESTING_THRESHOLD}}, {:internal_retweet_count => {:$gte => $INTERESTING_THRESHOLD}}, {:reply_count => {:$gte => $INTERESTING_THRESHOLD}}]).order(:created_at.desc).all
$pop_videos = $pop_videos.uniq_by{|x|x.videos.first.media_id}

# Collect interesting links
puts "Collecting urls"
$pop_urls = Hash.new(0)
Tweet.where(:following_tweet => true, :protected_tweet => false, :created_at.gte => 24.hours.ago, :urls.ne => []).order(:created_at.asc).all.each do |tweet|                  
  url = tweet.urls.first.expanded_url
  puts "nil" unless url
  unless !url || url.match(/\.(com|org|net|mv)\/*\Z/) || url.match(/\Ahttps*\:\/\/twitter\.com/) || url.match(/ustre\.am/) || url.match(/\/\/fb\.me/) || url.match(/\/\/4sq\.com/) || url.match(/\/\/instagr\.am/) || url.match(/imgur\.com/) || url.match(/youtube\.com/) || url.match(/youtu\.be/) || url.match(/twitpic\.com/) || url.match(/\.(jpg|png|gif)\Z/) || url.match(/yfrog\.com/) || url.match(/twittascope/) || url.match(/20ft\.net/) || url.match(/facebook\.com/)
    if $pop_urls[url] == 0
      $pop_urls[url] = {}
      $pop_urls[url]["tweet_id"] = tweet.tweet_id
      $pop_urls[url]["count"] = 1
      $pop_urls[url]["created_at"] = tweet.created_at
      $pop_urls[url]["user_ids"] = []
      $pop_urls[url]["user_ids"] << tweet.user.user_id
    else
      $pop_urls[url]["user_ids"] << tweet.user.user_id
      $pop_urls[url]["user_ids"] = $pop_urls[url]["user_ids"].uniq
      $pop_urls[url]["count"] = $pop_urls[url]["user_ids"].length
    end
  end
end
$pop_urls.delete_if{|k,v|v["count"] < $INTERESTING_THRESHOLD}

puts "Finding most retweeted people"
$retweeted_people = Hash.new(0)
Tweet.where(:following_tweet => true, :retweeted => true, :created_at.gte => 24.hours.ago).order(:internal_retweet_count.desc).all.each do |retweeted_tweet|
  $retweeted_people[retweeted_tweet.user.user_id] += retweeted_tweet.internal_retweet_count
end
$retweeted_people = $retweeted_people.sort_by{|k,v|v}.reverse[0..11]

puts "Finding most replied to people"
$replied_to_people = Hash.new(0)
Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :reply_count.gte => $INTERESTING_THRESHOLD).order(:reply_count.desc).all.each do |replied_tweet|
  $replied_to_people[replied_tweet.user.user_id] += replied_tweet.reply_count
end
$replied_to_people = $replied_to_people.sort_by{|k,v|v}.reverse[0..11]

puts "Finding most active people"
$active_people = Hash.new(0)
Tweet.where(:following_tweet => true, :created_at.gte => 24.hours.ago, :$or => [{:retweet_count => {:$gte => $INTERESTING_THRESHOLD_LOW}}, {:internal_retweet_count => {:$gte => $INTERESTING_THRESHOLD_LOW}}, {:reply_count => {:$gte => $INTERESTING_THRESHOLD_LOW}}]).order(:created_at.desc).all.group_by(&:user_id).each do |user_id, tweets_for_user|
  $active_people[User.find(user_id).user_id] = tweets_for_user.length
end
$active_people = $active_people.sort_by{|k,v|v}.reverse[0..11]
                                                     
puts "Saving digest"
daily_digest = DailyDigest.new
daily_digest.photos = $pop_photos    
daily_digest.videos = $pop_videos
daily_digest.retweeted_people = $retweeted_people
daily_digest.replied_to_people = $replied_to_people
daily_digest.active_people = $active_people
daily_digest.save

puts "Setting up resque tasks for links"
$pop_urls.each do |url|
  Resque.enqueue(DailyDigest, daily_digest._id, url[0], url[1]["created_at"], url[1]["tweet_id"], url[1]["count"])
end

