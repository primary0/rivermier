class PhotosController < ApplicationController

	respond_to :json

	def index
		respond_with Photo.includes(:tweets => :user).where("photos.url LIKE ? AND users.protected_user = ? AND users.following = ?", '%instagram.com%', false, true).page(params[:page]).per(10)
	end	
end
