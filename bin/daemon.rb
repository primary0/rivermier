#!/usr/bin/ruby

require 'rubygems'
require "bundler/setup"
require 'daemons'
  
Daemons.run('rivermier.rb')