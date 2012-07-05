require 'rubygems'
require 'mongo_mapper'
require 'active_support/all'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class Trend
  
  include MongoMapper::Document
    
  key :phrases, Array, :default => []
  key :hashtags, Array, :default => []
  key :created_at, Time
  
  many :tweets
  
  def self.tags_for_week
    return Trend.where(:created_at.gte => 7.days.ago).all.collect{|x|[x.phrases + x.hashtags]}.flatten.uniq
  end
  
  def self.daily_trends
    keywords = Trend.where(:created_at.gte => 24.hours.ago).order(:created_at.desc).all.collect{|x|[x.phrases + x.hashtags]}.flatten.uniq.sort
    return keywords.delete_if{|x|Trend.deletable(keywords,x)}    
  end
  
  def self.latest
    return Trend.order(:created_at.desc).limit(3).all
  end  
  
  def self.latest_all
    keywords = Trend.order(:created_at.desc).limit(3).all.collect{|x|[x.phrases + x.hashtags]}.flatten.uniq.sort
    return keywords.delete_if{|x|Trend.deletable(keywords,x)}
  end
  
  def self.latest_all_clean
    keywords = Trend.order(:created_at.desc).limit(3).all.collect{|x|[x.phrases + x.hashtags]}.flatten
    keywords = keywords.collect{|x|x.gsub(/\#/, "")}.uniq.sort
    return keywords.delete_if{|x|Trend.deletable(keywords,x)}
  end  
  
  def self.deletable(list, item)
    result = false
    list.each do |list_item|
      if list_item != item && list_item.match(/(:?\b|\#)(#{item})\b/i)
        result = true
      end 
    end
    return result
  end
  
  def self.latest_time
    Trend.order(:created_at.desc).first.nil? ? "" : Trend.order(:created_at.desc).first.created_at
  end
  
end