class Rivermier.Views.TweetsShow extends Backbone.View

	template: JST['tweets/show']
	actionButtons: JST['partials/action_buttons']
	
	tagName: 'li'

	events: ->
		'mouseover .tweet': 'mouseover'
		'mouseout .tweet': 'mouseout'

	render: ->
		user = @model.get('user')
		tweet = @model

		if tweet.get('retweet_count') >= 20
			@template = JST['tweets/large']		
		else if tweet.get('retweet_count') >= 15
			@template = JST['tweets/medium']
		$(@el).html(@template(tweet: tweet, user: user, actionButtons: @actionButtons))
		
		@after_render(this)
		this

	after_render: ->
		@timeago(this)
		$(@el).find('p').linkify(@toHashtagUrl);

	mouseover: ->
		$(@el).find('.action-buttons').show()

	mouseout: ->
		$(@el).find('.action-buttons').hide()

	timeago: ->
		$(@el).find('.time').timeago()

	toHashtagUrl: (hashtag) ->
		"https://twitter.com/search/?src=hash&q=%23" + hashtag