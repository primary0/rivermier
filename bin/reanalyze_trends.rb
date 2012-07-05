#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'active_support/all'

require File.expand_path(File.dirname(__FILE__) + '/../lib/tweet.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/trend.rb')

ommit_list = File.open(File.expand_path(File.dirname(__FILE__) + '/../reference/ignore.txt')).to_a.collect{|x|x.strip.downcase}
ommit_list = ommit_list.sort

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