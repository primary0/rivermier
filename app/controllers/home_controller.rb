class HomeController < ApplicationController
	def index
		gon.tweets = Tweet.includes(:user).where("tweets.retweeted = ?", true).limit(50)		
		gon.photos = Photo.includes(:tweets => :user).where("photos.url LIKE ? AND users.protected_user = ? AND users.following = ?", '%instagram.com%', false, true).limit(10)
		gon.videos = Video.includes(:tweets => :user).where("users.protected_user = ? AND users.following = ?", false, true).limit(6)
		gon.urls = Url.includes(:tweets => :user).where("users.protected_user = ? AND users.following = ? AND urls.title IS NOT ? AND urls.description IS NOT ? AND urls.description != ? AND tweets.retweet_count > ?", false, true, nil, nil, "", 1).limit(10)
	end
end
