xml.instruct! :xml, :version => '1.1'
xml.rss 'version' => '2.0' do
  xml.channel do
    xml.link "http://rivermier.com"
    xml.title "Rivermier Popular Tweets"
    xml.description "Real-time trending topics and popular posts by the Maldivian Twitter community."
    @retweets.each do |tweet|
      xml.item do
        xml.tweet_id tweet.tweet_id
        xml.screen_name tweet.user.screen_name
        xml.name tweet.user.name
        xml.profile_image_url tweet.user.profile_image_url
        xml.link "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.tweet_id}"
        xml.created_at tweet.created_at        
        xml.description tweet.text        
      end        
    end
  end
end