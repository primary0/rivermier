require 'rubygems'
require 'mongo_mapper'
require 'nokogiri'
require 'open-uri'

require File.expand_path(File.dirname(__FILE__) + '/../config/database.rb')
require File.expand_path(File.dirname(__FILE__) + '/tweet.rb')

class DailyDigest
  
  @queue = :digest_links
  
  include MongoMapper::Document
  
  key :photo_ids, Array, :default => [] 
  key :video_ids, Array, :default => [] 
  key :web_pages, Array, :default => []
  key :retweeted_people, Array, :default => []
  key :replied_to_people, Array, :default => []
  key :active_people, Array, :default => []
  timestamps!
  
  many :photos, :class_name => "Tweet", :in => :photo_ids  
  many :videos, :class_name => "Tweet", :in => :video_ids

  def self.perform(id, url, created_at, tweet_id, count)
    title = ""
    description = ""
    doc = Nokogiri::HTML(open(url))
    title = doc.xpath('//title').text
    description = doc.xpath('//description').text
    title = doc.xpath('//meta[@property="og:title"]').first["content"] if doc.xpath('//meta[@property="og:title"]').first
    image = doc.xpath('//meta[@property="og:image"]').first["content"] if doc.xpath('//meta[@property="og:image"]').first
    description = doc.xpath('//meta[@property="og:description"]').first["content"] if doc.xpath('//meta[@property="og:description"]').first
    site = doc.xpath('//meta[@property="og:site_name"]').first["content"] if doc.xpath('//meta[@property="og:site_name"]').first
    title = title.gsub(/SunOnline\s-\s/i, "") if title
    title = title.gsub(/HaveeruOnline\s-\s/i, "") if title
    title = title.gsub(/New\sDhivehi\sObserver\s-\s/i, "") if title
    temp = {
      :title => title,
      :description => description,
      :image => image,
      :site => site,
      :url => url,
      :created_at => created_at,
      :tweet_id => tweet_id,
      :count => count
    }
    unless title.empty? || description.empty? || title.strip.empty? || description.strip.empty?
      DailyDigest.push({:_id => id}, :web_pages => temp)
    end
  end

end