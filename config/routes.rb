Rivermier::Application.routes.draw do
	scope "api" do
		resources :tweets
		resources :photos
		resources :videos
		resources :urls
	end
	root to: 'home#index'
	match '*path', to: 'home#index'
end