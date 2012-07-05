class Rivermier.Views.UrlsIndex extends Backbone.View

	template: JST['urls/index']
	loading: JST['partials/loading']

	tagName: 'section'

	initialize: ->
		@collection.on('reset', @render, this)
		@collection.on('add', @appendNew, this)

	render: ->
		$(@el).html(@template(loading: @loading))
		@collection.each(@append, this)
		@infiniScroll = new Backbone.InfiniScroll(@collection, {includePage: true})
		@layout(this)
		this

	append: (item) ->
		view = new Rivermier.Views.UrlsShow(model: item)
		@$('#urls > .thumbnails').append(view.render().el)

	appendNew: (item) ->
		view = new Rivermier.Views.UrlsShow(model: item)
		views = [view.render().el]
		@$('#urls > .thumbnails').append(view.render().el).isotope('appended', $(view.render().el))
		@layout(this)

	layout: ->
		container = @$('#urls > .thumbnails')
		container.imagesLoaded ->
			container.isotope(itemSelector: '.tweet')	
			$('#urls > .loading').hide()
			$('.url-tweet').show()
			$('#loading-gif').show()
