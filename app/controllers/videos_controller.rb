class VideosController < ApplicationController

	respond_to :json

	def index
		respond_with Video.includes(:tweets => :user).where("users.protected_user = ? AND users.following = ?", false, true).page(params[:page]).per(6)
	end	
end