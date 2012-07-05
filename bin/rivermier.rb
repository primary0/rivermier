require 'rubygems'
require 'em-http'
require 'em-http/middleware/oauth'
require 'resque'
require 'multi_json'

require File.expand_path(File.dirname(__FILE__) + '/../config/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/dispatch.rb')

$URL = 'https://userstream.twitter.com/2/user.json?delimited=newline&replies=all'
$CONNECTION_TIMEOUT = 15
$INACTIVITY_TIMEOUT = 90

EM.run do
  
  OAuthConfig = {
    :consumer_key => $CONSUMER_KEY,
    :consumer_secret => $CONSUMER_SECRET,
    :access_token => $ACCESS_TOKEN,
    :access_token_secret => $ACCESS_TOKEN_SECRET
  }  
  
  MultiJson.engine = :yajl
  buffer = ''
  connection = EventMachine::HttpRequest.new($URL, :connection_timeout => $CONNECTION_TIMEOUT, :inactivity_timeout => $INACTIVITY_TIMEOUT, :keepalive => true)
  connection.use EventMachine::Middleware::OAuth, OAuthConfig
  http = connection.get(:head => {"User-Agent" => "User Agent","Accept-Encoding" => "deflate"})
  
  http.stream do |chunk|    
    
    buffer += chunk    
    while item = buffer.slice!(/.+\r?\n/)      
      item = MultiJson.decode(item)
      Resque.enqueue(Dispatch, item)
    end
  end

  http.errback do
    sleep 10
    exec('/home/rivermier/app/bin/./restart_script.sh')
  end
  
end
