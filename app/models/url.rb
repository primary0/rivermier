class Url < ActiveRecord::Base
	attr_accessible :url
  has_and_belongs_to_many :tweets
  validates_uniqueness_of :url
  validates_presence_of :url
  default_scope order: 'urls.created_at DESC'
  def as_json(options = {})
    { id: self.id,
      url: self.url,      
      title: self.title,      
      description: self.description,      
      image: self.image,      
      site_name: self.site_name,      
      tweet: self.top_tweet
    }
  end

  def top_tweet
  	self.tweets.order('retweet_count DESC').first
  end  

  def perform
		unless !self.url || self.url.match(/\.(com|org|net|mv)\/*\Z/) || self.url.match(/\Ahttps*\:\/\/twitter\.com/) || self.url.match(/ustre\.am/) || self.url.match(/\/\/fb\.me/) || self.url.match(/\/\/4sq\.com/) || self.url.match(/\/\/instagr\.am/) || self.url.match(/imgur\.com/) || self.url.match(/youtube\.com/) || self.url.match(/youtu\.be/) || self.url.match(/twitpic\.com/) || self.url.match(/\.(jpg|png|gif)\Z/) || self.url.match(/yfrog\.com/) || self.url.match(/twittascope/) || self.url.match(/20ft\.net/) || self.url.match(/facebook\.com/) || self.url.match(/lockerz\.com/)
			self.crawl
		end
  end

  def crawl
  	begin
	  	agent = Mechanize.new 
	  	page = agent.get(self.url)
	    return unless page
	    self.title = page.parser.xpath('//title').text
	    self.description = page.parser.xpath('//description').text
	    self.title = page.parser.xpath('//meta[@property="og:title"]').first["content"] if page.parser.xpath('//meta[@property="og:title"]').first
	    self.image = page.parser.xpath('//meta[@property="og:image"]').first["content"] if page.parser.xpath('//meta[@property="og:image"]').first
	    self.description = page.parser.xpath('//meta[@property="og:description"]').first["content"] if page.parser.xpath('//meta[@property="og:description"]').first
	    self.site_name = page.parser.xpath('//meta[@property="og:site_name"]').first["content"] if page.parser.xpath('//meta[@property="og:site_name"]').first
	    self.title = title.gsub(/SunOnline\s-\s/i, "") if self.title
	    self.title = title.gsub(/HaveeruOnline\s-\s/i, "") if self.title
	    self.title = title.gsub(/New\sDhivehi\sObserver\s-\s/i, "") if self.title
      self.image = nil unless self.image.match(/jpg\Z/) || self.image.match(/png\Z/)
	    self.save
  	rescue => e
  		Rails.logger.info(e)
  	end
  end
end