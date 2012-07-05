class Rivermier.Views.UrlsShow extends Backbone.View

	template: JST['urls/show']
	actionButtons: JST['partials/action_buttons']

	tagName: 'li'

	events: ->
		'mouseover .tweet': 'mouseover'
		'mouseout .tweet': 'mouseout'  

	render: ->
		user = @model.get('tweet').user
		tweet = @model.get('tweet')
		url = @model
		if tweet.retweet_count >= 100
			@template = JST['urls/large']		
		else if tweet.retweet_count >= 50
			@template = JST['urls/medium']
		$(@el).html(@template(tweet: tweet, user: user, url: url, actionButtons: @actionButtons))
		@after_render(this)
		this

	after_render: ->
		@timeago(this)
		$(@el).find('p').linkify(@toHashtagUrl);
		@styleThaana(this)

	styleThaana: ->
		if /haveeru\.com\.mv\/dhivehi|sun\.mv\/\d|manadhoolive|newdhivehiobserver|moonlight\.com\.mv|cnm\.com\.mv|dhitv\.com\.mv/.test(@model.get('url'))
			console.log("THAANA URL")
			$(@el).find(".url").addClass("thaana")

	mouseover: ->
		$(@el).find('.action-buttons').show()

	mouseout: ->
		$(@el).find('.action-buttons').hide()

	timeago: ->
		$(@el).find('.time').timeago()

	toHashtagUrl: (hashtag) ->
		"https://twitter.com/search/?src=hash&q=%23" + hashtag			
