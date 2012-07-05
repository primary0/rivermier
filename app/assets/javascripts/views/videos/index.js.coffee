class Rivermier.Views.VideosIndex extends Backbone.View

	template: JST['videos/index']
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
		view = new Rivermier.Views.VideosShow(model: item)
		@$('#videos > .thumbnails').append(view.render().el)

	appendNew: (item) ->
		view = new Rivermier.Views.VideosShow(model: item)
		views = [view.render().el]
		@$('#videos > .thumbnails').append(view.render().el).isotope('appended', $(view.render().el))

	layout: ->
		container = @$('#videos > .thumbnails')
		container.imagesLoaded ->
			$('#videos > .loading').hide()
			$('#videos > .thumbnails').show()
			$('#loading-gif').show()
			container.isotope(itemSelector: '.tweet')