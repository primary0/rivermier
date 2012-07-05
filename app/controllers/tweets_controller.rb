class TweetsController < ApplicationController

	respond_to :json

	def index
		respond_with Tweet.includes(:user).where("tweets.retweeted = ?", true).page(params[:page]).per(50)
	end
end
