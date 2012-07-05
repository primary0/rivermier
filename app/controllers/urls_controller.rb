class UrlsController < ApplicationController

	respond_to :json

	def index
		respond_with Url.includes(:tweets => :user).where("users.protected_user = ? AND users.following = ? AND urls.title IS NOT ? AND urls.description IS NOT ? AND urls.description != ? AND tweets.retweet_count > ?", false, true, nil, nil, "", 1).page(params[:page]).per(10)
	end		
end