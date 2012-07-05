#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'active_support/all'
require 'juggernaut'

require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/trend.rb')

ommit_list = File.open(File.expand_path(File.dirname(__FILE__) + '/../reference/ignore.txt')).to_a.collect{|x|x.strip.downcase}
ommit_list = ommit_list.sort

$MINIMUM_TWEETS_FOR_TREND = 25
$MINIMUM_FRIENDS_FOR_TREND = 10
$MINIMUM_PERCENTAGE_FOR_TREND = 5
$MINIMUM_COUNT_FOR_TREND = 5
$HOT_TREND_PERCENTAGE = 15

Trend.all.each do |trend|
  trend.phrases.each do |phrase|
    if ommit_list.include?(phrase)
      puts "Deleting #{phrase}"      
      Trend.pull(trend._id, :phrases => phrase)
    end
    if Trend.find(trend.id).phrases.empty?
      puts "Deleting trend object with #{phrase}"  
      Trend.find(trend._id).delete
    end    
  end
end

$tweets = Tweet.where(:following_tweet => true, :created_at.gte => 10.minutes.ago).all
$friends_count = $tweets.collect{|x|x.user_id}.uniq.count
puts "#{$tweets.count} tweets by #{$friends_count} friends selected"

$hot = {}
$words = {}
$phrases = {}
$hashtags = {}

def phraser(phrase)
  $tweets.each do |tweet|
    text = tweet.text.strip.gsub(/@[[:alnum:]]*/, "").gsub(/[[:punct:]][\s\t\n]+/, " ").gsub(/\r\t\n/,"").gsub(/[[:punct:]]*\Z/,"").downcase.squeeze(" ").strip
    if text.match(/\b#{phrase}\b/i)
      unless $phrases[phrase]
        $phrases[phrase] = {}
        $phrases[phrase]["user_ids"] = []
        $phrases[phrase]["count"] = 0
      end
      unless $phrases[phrase]["user_ids"].include?(tweet.user_id)
        $phrases[phrase]["user_ids"] << tweet.user_id
        $phrases[phrase]["count"] += 1        
        text.scan(/\b#{phrase}[\s{1}\w+]*/i).each do |match_phrase|
          match_phrase = match_phrase.downcase
          match_phrase = match_phrase.strip
          match_phrase = match_phrase.squeeze(" ")
          phraser(match_phrase)        
        end
      end      
    end
  end  
end

if $tweets.count >= $MINIMUM_TWEETS_FOR_TREND && $friends_count >= $MINIMUM_FRIENDS_FOR_TREND
  
  puts "Collecting hashtags"
  $tweets.each do |tweet|
    tweet.hashtags.each do |hashtag|
      unless $hashtags[hashtag.text]
        $hashtags[hashtag.text] = {}
        $hashtags[hashtag.text]["user_ids"] = []
        $hashtags[hashtag.text]["count"] = 0
      end
      unless $hashtags[hashtag.text]["user_ids"].include?(tweet.user_id)
        $hashtags[hashtag.text]["user_ids"] << tweet.user_id
        $hashtags[hashtag.text]["count"] += 1
      end
    end
  end
  
  puts "Calculating word frequencies"
  $tweets.each do |tweet|
    tweet.text.strip.squeeze(" ").split(" ").each do |word|    
      word = word.downcase        
      word = word.gsub(/@\w+/, "")            
      word = word.gsub(/#\w+/, "")            
      word = word.gsub(/\A\d+\Z/, "")
      word = "" if word.match(/\bhttp/)      
      word = word.gsub(/[^a-zA-Z0-9-]/, "")
      word = word.squeeze(" ")
      word = word.strip
      if word != nil && word.length > 1
        if $words[word]
          $words[word] += 1
        else
          $words[word] = 1
        end      
      end
    end
  end  
  $words = $words.sort_by{|k,v|v}
  
  puts "Detecting phrases"
  $words.each do |word|
    phraser(word.first)
  end
  
  $phrases.each do |k, v|    
    if ommit_list.include?(k)
      $phrases.delete(k)
    elsif
      to_delete = true
      k.split(" ").each do |word|
        word = word.gsub(/[[:punct:]]/, "").squeeze(" ").strip
        if !ommit_list.include?(word)
          to_delete = false
          break          
        end
      end
      $phrases.delete(k) if to_delete
    elsif k.split(" ").length > 3
      $phrases.delete(k)      
    end 
  end
  $phrases = $phrases.sort_by{|k,v|v["count"]}
  
  puts "Detecting trending phrases"
  phrases = []
  $phrases.each do |key, value|
    percentage = ((value["count"].to_f/$friends_count.to_f)*100).round(2)
    if value["count"] >= $MINIMUM_COUNT_FOR_TREND && percentage >= $MINIMUM_PERCENTAGE_FOR_TREND
      phrases << key
      if percentage >= $HOT_TREND_PERCENTAGE
        $hot[key] = percentage
      end
    end
  end
  
  puts "Detecting trending hashtags"
  hashtags = []
  $hashtags.each do |key, value|
    percentage = ((value["count"].to_f/$friends_count.to_f)*100).round(2)
    if value["count"] >= $MINIMUM_COUNT_FOR_TREND && percentage >= $MINIMUM_PERCENTAGE_FOR_TREND
      hashtags << "##{key}"
      if percentage >= $HOT_TREND_PERCENTAGE
        $hot["##{key}"] = percentage
      end
    end
  end     
  
  unless phrases.empty? && hashtags.empty?
    puts "Publishing trends"
    puts "Phrases: #{phrases.join(', ')}"
    puts "Hashtags: #{hashtags.join(', ')}"
    Trend.create(:phrases => phrases, :hashtags => hashtags, :created_at => Time.now)
    response = {
      "trends" => Trend.latest_all,
      "time" => Time.now.iso8601
    }
    Juggernaut.publish("trends", response.to_json)
  else
    puts "No trends found"
  end
  
  unless $hot.empty?
    puts "Publishing HOT trend"
    response = {
      "hot_trends" => $hot,
      "time" => Time.now
    }
    Juggernaut.publish("test", response.to_json)
  end  
  
end