class Rivermier.Views.HomeNavigation extends Backbone.View

	template: JST['home/navigation']
	tagName: 'div'
	className: 'navbar navbar-fixed-top'

	render: ->
		$(@el).html(@template())
		this

	events: ->
		'click #nav-link-tweets' : 'tweets'
		'click #nav-link-photos' : 'photos'
		'click #nav-link-videos' : 'videos'
		'click #nav-link-urls' : 'urls'

	tweets: ->
		Backbone.history.navigate("", true)

	photos: ->
		Backbone.history.navigate("instagram/", true)

	videos: ->
		Backbone.history.navigate("youtube/", true)

	urls: ->
		Backbone.history.navigate("news/", true)