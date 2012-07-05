#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'active_support/all'

require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/daily_digest.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/trend.rb')

puts "Deleting #{Tweet.where(:retweeted => false, :created_at.lt => 10.days.ago).count} tweets older than 10 days"
Tweet.delete_all(:retweeted => false, :created_at.lt => 10.days.ago)

puts "Deleting #{Tweet.where(:retweeted => false, :following_tweet => false, :created_at.lt => 3.days.ago).count} non following tweets older than 3 days"
Tweet.delete_all(:retweeted => false, :following_tweet => false, :created_at.lt => 3.days.ago)
 
puts "Deleting #{DailyDigest.where(:created_at.lt => 10.days.ago).count} daily digests older than 10 days"
DailyDigest.delete_all(:created_at.lt => 10.days.ago)

puts "Deleting #{Trend.where(:created_at.lt => 10.days.ago).count} trends older than 10 days"
Trend.delete_all(:created_at.lt => 10.days.ago)