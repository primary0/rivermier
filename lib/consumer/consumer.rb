require 'rubygems'
require 'em-http'
require 'em-http/middleware/oauth'
require 'multi_json'

class Consumer
  $OAuthConfig = {
    consumer_key: ENV['CONSUMER_KEY'],
    consumer_secret: ENV['CONSUMER_SECRET'],
    access_token: ENV['ACCESS_TOKEN'],
    access_token_secret: ENV['ACCESS_TOKEN_SECRET']
  }
  def perform
    EM.run do
      MultiJson.engine = :yajl
      buffer = ''
      connection = EventMachine::HttpRequest.new(ENV['URL'], connection_timeout: ENV['CONNECTION_TIMEOUT'], inactivity_timeout: ENV['INACTIVITY_TIMEOUT'], keepalive: true)
      connection.use EventMachine::Middleware::OAuth, $OAuthConfig
      http = connection.get(head: {"User-Agent" => "User Agent","Accept-Encoding" => "deflate"})      
      http.stream do |chunk|            
        buffer += chunk    
        while item = buffer.slice!(/.+\r?\n/)      
          item = MultiJson.decode(item)
          Dispatch.delay.perform(item)
        end
      end
      http.errback do
        EM.stop
      end
      http.callback do
        EM.stop
      end
    end
  end
end
