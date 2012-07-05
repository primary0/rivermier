class Rivermier.Routers.Home extends Backbone.Router

	routes:
		'': 'tweets'
		'instagram/': 'instagram'
		'youtube/': 'youtube'
		'news/': 'news'

	initialize: ->
		navigationView = new Rivermier.Views.HomeNavigation()
		$('body').prepend(navigationView.render().el)

		@tweetsCollection = new Rivermier.Collections.Tweets()
		@tweetsCollection.reset(gon.tweets)

		@photosCollection = new Rivermier.Collections.Photos()
		@photosCollection.reset(gon.photos)

		@videosCollection = new Rivermier.Collections.Videos()
		@videosCollection.reset(gon.videos)		

		@urlsCollection = new Rivermier.Collections.Urls()
		@urlsCollection.reset(gon.urls)						

		@twitterConnectButton(this)

	tweets: ->	
		view = new Rivermier.Views.TweetsIndex(collection: @tweetsCollection)		
		$('#contents').html(view.render().el)
		@linkifyTwitterUsernames(this)

	instagram: ->
		view = new Rivermier.Views.PhotosIndex(collection: @photosCollection)		
		$('#contents').html(view.render().el)
		@linkifyTwitterUsernames(this)

	youtube: ->
		view = new Rivermier.Views.VideosIndex(collection: @videosCollection)		
		$('#contents').html(view.render().el)
		@linkifyTwitterUsernames(this)

	news: ->
		view = new Rivermier.Views.UrlsIndex(collection: @urlsCollection)		
		$('#contents').html(view.render().el)
		@linkifyTwitterUsernames(this)

	twitterConnectButton: ->
		twttr.anywhere (T) ->
			T("#login").connectButton();

	linkifyTwitterUsernames: ->
		twttr.anywhere (T) ->
			T.hovercards({expanded: true})
			